class FreshdeskLocal::Contact < ActiveRecord::Base
  self.table_name_prefix = 'freshdesk_local_'

  validates :email, presence: true
  validates :name, presence: true
  validates :freshdesk_id, presence: true
end
