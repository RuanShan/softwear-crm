require 'spec_helper'

describe Api::JobsController, api_spec: true, story_198: true do
  it_behaves_like "api_controller index"
end