require 'spec_helper'

describe ApplicationHelper, application_helper_spec: true do
  describe '#model_table_row_id' do
    let! (:shipping_method) { create(:valid_shipping_method) }

    it 'returns the model name underscored and with the record id at the end' do
      expect(model_table_row_id(shipping_method)).to eq("shipping_method_#{shipping_method.id}")
    end
  end

  describe '#create_or_edit_text' do

    context 'object is a new record' do
      it 'returns Create' do
        expect(create_or_edit_text(ShippingMethod.new)).to eq('Create')
      end
    end

    context 'object is an existing record' do
      let! (:shipping_method) { create(:valid_shipping_method) }

      it 'returns Update' do
        expect(create_or_edit_text(shipping_method)).to eq('Update')
      end
    end
  end

  describe '#human_boolean' do
    it 'returns Yes when given a true value' do
      expect(human_boolean(true)).to eq('Yes')
    end
    it 'returns No when given a false value' do
      expect(human_boolean(false)).to eq('No')
    end
  end

  describe '#display_time' do
    context 'datetime is nil' do
      it 'returns nil' do
        expect(display_time('')).to eq(nil)
      end
    end

    context 'there is a valid datetime' do
      let!(:datetime) { DateTime.new(1991, 9, 25) }
      it 'returns a formatted date' do
        expect(display_time(datetime)).to eq('Sep 25, 1991, 12:00 AM')
      end
    end
  end

  context 'freshdesk time parsing', story_70: true do
    let!(:fd_time) { '2014-10-29T19:00:45-04:00' }

    describe '#display_freshdesk_time' do
      it 'returns a nicely formatted date' do
        expect(display_freshdesk_time(fd_time)).to eq('Oct 29, 2014, 07:00 PM')
      end
    end

    describe '#parse_freshdesk_time' do
      let!(:format_string) { '%Y-%m-%dT%H:%M:%S' }
      it 'returns a datetime object' do
        expect(parse_freshdesk_time(fd_time)).to eq(DateTime.new(2014, 10, 29, 19, 0, 45))
      end
    end
  end
end
