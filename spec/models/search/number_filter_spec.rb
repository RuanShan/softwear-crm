require 'spec_helper'

describe Search::NumberFilter, search_spec: true do
  it { should inherit_from 'Search::Filter' }
end