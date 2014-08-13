require 'spec_helper'

describe ShippingMethod do

  it { is_expected.to be_paranoid }

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to allow_value('http://www.foo.com', 'http://www.foo.com/shipping').for(:tracking_url) }
    it { is_expected.to_not allow_value('bad_url.com', '').for(:tracking_url).with_message('should be in format http://www.url.com/path') }
  end
end