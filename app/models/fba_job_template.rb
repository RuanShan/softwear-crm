class FbaJobTemplate < ActiveRecord::Base
  has_many :fba_imprint_templates, dependent: :destroy, inverse_of: :fba_job_template
  has_many :artworks, through: :fba_imprint_templates
  has_many :fba_skus, dependent: :destroy
  has_one :mockup, as: :assetable, class_name: 'Asset', dependent: :destroy

  accepts_nested_attributes_for :fba_imprint_templates, allow_destroy: true
  accepts_nested_attributes_for :mockup

  validates :name, presence: true, uniqueness: true

  scope :with_mockup, -> { where.not(mockup: nil) }
  scope :without_mockup, -> { where(mockup: nil) }

  searchable do
    text :name, :job_name
    string :name
    string :job_name
    boolean :needs_artwork
    boolean :needs_proof
    integer :imprint_count
    integer :id
  end

  def needs_artwork
    artworks.size < fba_imprint_templates.size
  end
  alias_method :needs_artwork?, :needs_artwork

  def needs_proof
    mockup.blank? || mockup.file.blank?
  end
  alias_method :needs_proof?, :needs_proof

  def job_name
    n = super
    n.blank? ? name : n
  end

  def mockup_attributes=(attrs)
    attrs = attrs.with_indifferent_access
    return if attrs[:file].blank?

    attrs[:description] = "FBA #{name} proof mockup"
    super(attrs)
  end

  def imprint_count
    fba_imprint_templates.size
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

  private
end
