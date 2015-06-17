require 'spec_helper'

describe Setting, setting_spec: true do

  it { is_expected.to be_paranoid }

  describe '.insightly_api_key', story_513: true do
    it 'returns the setting with the name "insightly_api_key"' do
      Setting.create(name: 'insightly_api_key', val: '123insightly', encrypted: false)
      expect(Setting.insightly_api_key).to eq '123insightly'
    end
  end

  describe '.get_freshdesk_settings' do
    context 'when setting records are present' do
      it 'sets the freshdesk_hash to its values' do
        expected_hash = {
          freshdesk_email: Setting.create(name: 'freshdesk_email',
                     val: 'test@test.com',
                     encrypted: false).val(),
          freshdesk_url: Setting.create(name: 'freshdesk_url',
                     val: 'freshdesk.com',
                     encrypted: false).val(),
          freshdesk_password: Setting.create(name: 'freshdesk_password',
                     val: 'something',
                     encrypted: true).val()
        }
        expect(Setting.get_freshdesk_settings).to eq expected_hash
      end
    end

    context 'when setting are not present' do
      context 'when environment variables are present' do
        it 'sets the freshdesk_hash to the environment variables' do
          expect(Setting).to receive(:find_by).exactly(3).times.and_return(nil)
          expect(Figaro).to receive(:env).exactly(3).times.and_return({
            'freshdesk_email' => 'aww ye',
            'freshdesk_url' => 'uh',
            'freshdesk_password' => 'yeeee'
          })

          ret_val = Setting.get_freshdesk_settings

          expect(ret_val[:freshdesk_email]).to eq('aww ye')
          expect(ret_val[:freshdesk_url]).to eq('uh')
          expect(ret_val[:freshdesk_password]).to eq('yeeee')
        end
      end

      context 'when environment variables are not present' do
        it 'returns a hash of settings with nil values' do
          expect(Setting).to receive(:find_by).exactly(3).times.and_return(nil)
          expect(Figaro).to receive(:env).exactly(3).times.and_return({})

          ret_val = Setting.get_freshdesk_settings

          expect(ret_val).to eq(nil)
        end
      end
    end
  end
end
