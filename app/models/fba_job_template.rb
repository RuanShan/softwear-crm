class FbaJobTemplate < ActiveRecord::Base
  has_many :fba_imprint_templates, dependent: :destroy, inverse_of: :fba_job_template
  accepts_nested_attributes_for :fba_imprint_templates, allow_destroy: true

  validates :name, presence: true, uniqueness: true

  searchable do
    text :name, :job_name
  end

  def job_name
    n = super
    n.blank? ? name : n
  end
end
