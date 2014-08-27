require 'spec_helper'
require_relative '../../../../../app/models/imprintable'

describe Api::ImprintablesController, api_imprintable_spec: true do
  context 'test' do
    it 'uhh we can access imprintable' do
      expect{Imprintable}.to_not raise_error
    end
  end

  describe 'GET #index' do
    # Okay, this stuff won't work probably. So maybe just move
    # the API stuff into the base app and think about modularizing
    # later.
  end
end