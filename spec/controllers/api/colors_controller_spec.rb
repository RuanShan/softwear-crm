require 'spec_helper'
include ApiControllerTests

describe Api::ColorsController, api_color_spec: true, api_spec: true do
  it_behaves_like 'api_controller'
end