class LineItemTemplate < ActiveRecord::Base
  validates :name, :description, presence: true

  searchable do
    text :name, :description, :url
  end
end
