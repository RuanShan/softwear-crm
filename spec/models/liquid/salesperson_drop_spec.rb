require 'spec_helper'

describe SalespersonDrop, liquid: true do
  subject { SalespersonDrop.new(build(:user) ) }
  it { is_expected.to respond_to :first_name }
  it { is_expected.to respond_to(:last_name) }
  it { is_expected.to respond_to :full_name }
  it { is_expected.to respond_to :email }
end
