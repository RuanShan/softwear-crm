class LineItemTemplate < ActiveRecord::Base
  validates :name, :description, presence: true

  searchable do
    text :name, :description, :url
    integer :id
  end
end
