require 'spec_helper'

describe Api::OrdersController, api_spec: true, story_199: true do
  it_behaves_like 'api_controller index'
end