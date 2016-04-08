class OrderQuote < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :order
  belongs_to :quote

  validate :transition_quote, on: :create

  def transition_quote
    quote.won
    unless quote.save
      errors.add(:quote, "Failed to transition quote state: #{quote.errors.full_messages.join(', ')}")
    end
  end
end
