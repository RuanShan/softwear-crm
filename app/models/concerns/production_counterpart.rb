module ProductionCounterpart
  extend ActiveSupport::Concern

  included do
    cattr_accessor :production_class
    begin
      self.production_class = "Production::#{name}".constantize
    rescue NameError => _
    end

    before_save :enqueue_update_production, if: :should_update_production?
    after_destroy :enqueue_destroy_production, if: :should_update_production?

    try :warn_on_failure_of, :update_production unless Rails.env.test?

    if Rails.env.production?
      def enqueue_update_production
        delay(queue: 'api').update_production(update_production_fields)
      end

      def enqueue_destroy_production
        delay(queue: 'api').destroy_production
      end
    else
      alias_method :enqueue_update_production, :update_production
      alias_method :enqueue_destroy_production, :destroy_production
    end

    def self.fetch_production_ids(start_date = nil)
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

    def self.production_polymorphic?
      production_class == :polymorphic
    end

    def self.production_class
      if production_polymorphic?
        return nil if softwear_prod_type.blank?
        softwear_prod_type.constantize
      else
        @production_class
      end
    end
  end

  def production_class
    self.class.production_class
  end
  def production_polymorphic?
    self.class.production_polymorphic?
  end

  def production
    return nil if production_class.nil? || softwear_prod_id.nil?
    @production ||= production_class.find(softwear_prod_id)
  end

  def production?
    !softwear_prod_id.nil?
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
    production.destroy
    self.update_column :softwear_prod_id, nil
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
