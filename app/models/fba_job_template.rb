class FbaJobTemplate < ActiveRecord::Base
  has_many :fba_job_template_imprints, inverse_of: :fba_job_template, dependent: :destroy
  has_many :imprints, through: :fba_job_template_imprints, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  after_save :assign_imprints

  searchable do
    text :name
  end

  def print_location_ids
    imprints.pluck(:print_location_id)
  end
  attr_writer :print_location_ids

  def imprint_descriptions
    imprints.pluck(:description)
  end
  attr_writer :imprint_descriptions

  def imprints_attributes
    hash = {}
    imprints.each do |imprint|
      hash[imprint.id] = {
        print_location_id: imprint.print_location_id,
        description:       imprint.description
      }
    end
    hash
  end

  private

  def assign_imprints
    return if @print_location_ids.nil? && @imprint_descriptions.nil?
    imprints.destroy_all if imprints.any?

    imprint_count = [@print_location_ids, @imprint_descriptions].map(&:size).max
    imprint_count.times do |index|
      fba_job_template_imprints.create(
        fba_job_template_id: id,
        imprint: Imprint.create!(
          print_location_id: @print_location_ids[index],
          description: @imprint_descriptions[index]
        )
      )
    end

    @print_location_ids = nil
    @imprint_descriptions = nil
  end
end
