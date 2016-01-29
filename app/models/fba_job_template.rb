class FbaJobTemplate < ActiveRecord::Base
  has_many :fba_imprint_templates, dependent: :destroy, inverse_of: :fba_job_template
  has_one :mockup, as: :assetable, class_name: 'Asset'

  accepts_nested_attributes_for :fba_imprint_templates, allow_destroy: true
  accepts_nested_attributes_for :mockup

  validates :name, presence: true, uniqueness: true
  validate :mockup_uploaded

  searchable do
    text :name, :job_name
  end

  def job_name
    n = super
    n.blank? ? name : n
  end

  def mockup_attributes=(attrs)
    return if attrs[:file].blank?
    attrs[:description] = "FBA #{name} proof mockup"
    super(attrs)
  end

  def imprints_attributes
    hash = {}
    fba_imprint_templates.each_with_index do |imprint, index|
      hash[index] = {
        print_location_id: imprint.print_location_id,
        description:       imprint.description
      }
    end
    hash
  end

  def mockup
    super || Asset.new
  end

  private

  def mockup_uploaded
    if mockup.file.blank?
      errors.add(:mockup, "must be uploaded")
    end
  end
end
