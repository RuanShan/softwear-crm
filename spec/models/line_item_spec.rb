require 'spec_helper'

describe LineItem, line_item_spec: true do
  context 'when validating' do
    it { should validate_presence_of :name }
  end
end