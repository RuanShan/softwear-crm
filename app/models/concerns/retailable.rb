module Retailable
  extend ActiveSupport::Concern

  included do
    validates :sku, uniqueness: true, presence: true, if: :is_retail?
  end

  def is_retail?
    retail == true
  end

end