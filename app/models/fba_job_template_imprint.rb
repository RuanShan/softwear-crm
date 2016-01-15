class FbaJobTemplateImprint < ActiveRecord::Base
  belongs_to :fba_job_template, inverse_of: :fba_job_template_imprints
  belongs_to :imprint, dependent: :destroy
end
