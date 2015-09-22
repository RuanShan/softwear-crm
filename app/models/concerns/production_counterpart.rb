module ProductionCounterpart
  extend ActiveSupport::Concern

  included do
    cattr_accessor :production_class
    self.production_class = "Production::#{name}".constantize

    after_save :clear_production
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

  protected

  def clear_production
    @production = nil
  end
end
