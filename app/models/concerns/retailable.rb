module Retailable
  extend ActiveSupport::Concern

  included do
    validates :sku, uniqueness: true, presence: true, if: :is_retail? && -> {!instance_of? Imprintable}
    validates :style_sku, uniqueness: true, presence: true, if: :is_retail? && -> {instance_of? Imprintable}
  end

  def is_retail?
    retail == true
  end
end