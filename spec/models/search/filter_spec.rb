require 'spec_helper'

describe Search::Filter, search_spec: true do
  it { should belong_to :filter_holder, polymorphic: true }
  it { should belong_to :filter_type, polymorphic: true }

  it { should validate_presence_of :filter_type }
end