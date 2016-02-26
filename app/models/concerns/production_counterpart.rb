module ProductionCounterpart
  extend ActiveSupport::Concern

  module ClassMethods
    def fetch_production_ids(start_date = nil)
      start_date ||= 1.month.ago

      updated_count = 0
      where('softwear_prod_id IS NULL AND created_at > ?', start_date).find_each do |record|
        if prod_record = production_class.where(softwear_crm_id: record.id).first
          record.update_column :softwear_prod_id, prod_record.id
          updated_count += 1
        end
      end
      updated_count
    end

    def production_polymorphic?
      @production_class == :polymorphic
    end

    def production_class=(value)
      @production_class = value
    end

    def production_class
      @production_class
    end
  end

  included do
    extend ClassMethods
    unless included_modules.include?(Softwear::Lib::Enqueue)
      include Softwear::Lib::Enqueue
    end

    begin
      self.production_class = "Production::#{name}".constantize
    rescue NameError => _
    end

    try :warn_on_failure_of, :update_production unless Rails.env.test?
    enqueue :update_production, :destroy_production, queue: 'api'

    before_save :enqueue_update_production, if: :should_update_production?
    after_destroy :enqueue_destroy_production, if: :should_update_production?

    if Rails.env.production?
      # Override enqueue method to always pass update_production_fields
      def enqueue_update_production
        self.class.delay(queue: 'api').update_production(id, update_production_fields)
      end
    end
  end

  def production_class
    if production_polymorphic?
      return nil if softwear_prod_type.blank?
      softwear_prod_type.constantize
    else
      self.class.production_class
    end
  end
  def production_polymorphic?
    self.class.production_polymorphic?
  end

  def production
    return nil if production_class.nil? || softwear_prod_id.nil?
    @production ||= production_class.find(softwear_prod_id)
  rescue ActiveResource::ResourceNotFound => _
    @production = nil
  end

  def production_exists?
    !!production
  end

  def production?
    !!softwear_prod_id
  end

  def sync_with_production(sync)
    # Override this!
    # See order.rb, job.rb, or imprint.rb for examples.
  end

  def production_url
    base = Figaro.env.production_url
    return if base.blank? || !production?

    "#{base}/#{production_class.model_name.element.pluralize}/#{softwear_prod_id}"
  end

  def should_update_production?
    production? && valid?
  end

  def update_production(fields = nil)
    return unless production_exists?

    fields = update_production_fields if fields.nil?
    return if fields.empty?

    fields.each do |f|
      p_field, c_field = f.first
      production.send("#{p_field}=", send(c_field))
    end

    @production.save!
    @production = nil
  end

  def destroy_production
    production.destroy if production_exists?
    self.update_column :softwear_prod_id, nil
  rescue ActiveRecord::ActiveRecordError => _
  end

  protected

  def update_production_fields
    results = []

    sync_with_production(->(field) {
      if field.is_a?(Hash)
        p_field, c_field = field.first
      else
        p_field = field
        c_field = field
      end

      field_was_changed = "#{c_field}_changed?"
      if !respond_to?(field_was_changed) || send(field_was_changed)
        results << { p_field => c_field }
      end
    })

    results
  end
end
