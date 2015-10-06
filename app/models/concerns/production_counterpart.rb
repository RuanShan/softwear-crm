module ProductionCounterpart
  extend ActiveSupport::Concern

  included do
    cattr_accessor :production_class
    self.production_class = "Production::#{name}".constantize

    after_save :enqueue_update_production, if: :production?

    try :warn_on_failure_of, :update_production unless Rails.env.test?

    if Rails.env.production?
      def enqueue_update_production
        delay(queue: 'api').update_production
      end
    else
      alias_method :enqueue_update_production, :update_production
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
  end

  def production_url
    base = Figaro.env.production_url
    return if base.blank? || !production?

    "#{base}/#{model_name.collection}/#{softwear_prod_id}"
  end

  def update_production
    changed = false

    sync_with_production(->(field) {
      if field.is_a?(Hash)
        p_field, c_field = field.first
      else
        p_field = field
        c_field = field
      end

      if send("#{c_field}_changed?")
        production.send("#{p_field}=", send(c_field))
        changed = true
      end
    })

    @production.save! if changed?
    @production = nil
  end
end
