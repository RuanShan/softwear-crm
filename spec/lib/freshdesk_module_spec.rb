require 'spec_helper'

describe FreshdeskModule, freshdesk_spec: true, pending: 'Freshdesk ._.' do
  include FreshdeskModule

  class DummyClass
  end

  before(:all) do
    @dummy = DummyClass.new
    @dummy.extend FreshdeskModule
  end

  describe '.get_freshdesk_config'

  describe '.open_connection'

  describe '.send_ticket'
end
