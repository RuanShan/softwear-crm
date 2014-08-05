class CoordinateImprintable < ActiveRecord::Base
  acts_as_paranoid

  after_create :add_mirror
  after_destroy :destroy_mirror
  after_update :update_mirror

  belongs_to :coordinate, class_name: 'Imprintable'
  belongs_to :imprintable

  validates :coordinate, presence: true
  validates :imprintable, presence: true

  # TODO: try to refactor
  def add_mirror
    self.class.find_or_create_by(imprintable: coordinate,
                                 coordinate: imprintable)
  end

  def update_mirror
    if self.changed?
      mirror = CoordinateImprintable.find_by(coordinate_id: imprintable_id_was,
                                             imprintable_id: coordinate_id_was)

      mirror.update_columns(imprintable_id: coordinate_id,
                            coordinate_id: imprintable_id)
    end
  end

  def destroy_mirror
    mirror = self.class.find_by(imprintable: coordinate,
                                coordinate: imprintable)

    mirror.destroy if mirror && mirror.deleted_at.nil?
  end
end
