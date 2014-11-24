require 'spec_helper'

describe FreshdeskModule, freshdesk_spec: true do
  include FreshdeskModule

  class DummyClass
  end

  before(:all) do
    @dummy = DummyClass.new
    @dummy.extend FreshdeskModule
  end

  context 'pending', pending: 'Freshdesk ._.' do
    describe '.get_freshdesk_config'

    describe '.open_connection'

    describe '.send_ticket'
  end

  describe '.get_contacts', story_262: true do
    before(:each) do
      expect(Setting).to receive(:get_freshdesk_settings).and_return({freshdesk_url: 'http://annarbortees.freshdesk.com/'})
    end

    after(:each) { FreshdeskModule.get_contacts(1) }

    it 'creates a new RestClient' do
      expect(DummyClass).to receive(:get).and_return '[]'
      expect(RestClient::Resource).to receive(:new).and_return DummyClass
    end

    it 'parses a json response' do
      expect(JSON).to receive(:parse)
    end
  end
end
