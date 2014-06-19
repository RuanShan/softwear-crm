require 'spec_helper'

describe Search::BooleanFilter, search_spec: true do
  it { should be kind_of Search::FilterType }
end