module ProductionCounterpart
  extend ActiveSupport::Concern

  included do
    cattr_accessor :production_class
    self.production_class = "Production::#{name}".constantize

    before_save :enqueue_update_production, if: :should_update_production?

    try :warn_on_failure_of, :update_production unless Rails.env.test?

    if Rails.env.production?
      def enqueue_update_production
        delay(queue: 'api').update_production(update_production_fields)
      end
    else
      alias_method :enqueue_update_production, :update_production
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
  end

  def production_class
    self.class.production_class
  end

  def production
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

    "#{base}/#{model_name.collection}/#{softwear_prod_id}"
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
