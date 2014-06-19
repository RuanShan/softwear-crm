class CoordinateImprintable < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :imprintable
  belongs_to :coordinate, class_name: 'Imprintable'
  after_create :add_mirror
  after_update :update_mirror
  after_destroy :destroy_mirror

  def add_mirror
    self.class.find_or_create_by(imprintable: coordinate, coordinate: imprintable)
  end

  def update_mirror
    if self.changed?
      mirror = self.class.find(imprintable: coordinate_was, coordinate: imprintable_was)
      mirror.update_attributes(imprintable: coordinate, coordinate: imprintable)
    end
  end

  def destroy_mirror
    mirror = self.class.find(imprintable: coordinate, coordinate: imprintable)
    mirror.destroy if mirror && !mirror.destroyed
  end
end
