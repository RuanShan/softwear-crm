require 'spec_helper'

describe UrlHelper, story_75: true do
  describe '#url_with_protocol' do

    context 'url does not have protocol' do
      it 'gives the url a protocol' do
        expect(url_with_protocol('google.com')).to eq('http://google.com')
      end
    end

    context 'url has protocol' do
      it 'does not change the url' do
        expect(url_with_protocol('http://google.com')).to eq('http://google.com')
      end
    end
  end
end