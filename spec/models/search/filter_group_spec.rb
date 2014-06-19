require 'spec_helper'

describe Search::FilterGroup, search_spec: true do
  it { should have_many :filters }
  it { should belong_to :filter_holder, polymorphic: true }

  it { should have_many :filter_groups, as: :filter_holder }
  
end