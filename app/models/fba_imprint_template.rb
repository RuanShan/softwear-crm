class FbaImprintTemplate < ActiveRecord::Base
  belongs_to :print_location
  belongs_to :artwork
  belongs_to :fba_job_template, inverse_of: :fba_imprint_templates

  def imprint_method
    print_location.try(:imprint_method)
  end

  def imprint_method_id
    imprint_method.try(:id)
  end
end
