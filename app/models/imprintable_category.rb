class ImprintableCategory < ActiveRecord::Base
  VALID_CATEGORIES = [
    '',
    'Tees & Tanks',
    'Sweatshirts & Fleece',
    'Pants & Shorts',
    'Business & Industrial Wear',
    'Jackets',
    'Headwear & Bags',
    'Athletics',
    'Fashionable',
    'Youth',
    'Something Different',
    'What\'s Least Expensive'
  ]

  belongs_to :imprintable

  #TODO: does validates :name need to be called twice?
  validates :name, inclusion: { in: VALID_CATEGORIES, message: 'Invalid category' }
  validates :name, uniqueness: { scope: :imprintable }, presence: true
end
