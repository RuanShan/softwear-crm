require 'spec_helper'

describe Search::DateFilter, search_spec: true do
  it { should inherit_from 'Search::Filter' }
end