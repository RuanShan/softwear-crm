class Job < ActiveRecord::Base
  belongs_to :order

  validates_presence_of :name
  validates :name, uniqueness: { scope: :order_id }

  # non-deletable stuff
  inject NonDeletable, track_methods: true

  def destroy
    original_destroy
    update_attribute :name, "#{name} #{Time.now.to_s}"
  end

  def destroy!
    original_destroy!
    update_column update_attribute :name, "#{name} #{Time.now.to_s}"
  end
end
