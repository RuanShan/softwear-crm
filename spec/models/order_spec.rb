require 'spec_helper'

describe Order do
  context 'when validating' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :firstname }
    it { should validate_presence_of :lastname }

    it { should validate_presence_of :name }
    it { should validate_presence_of :terms }
    it { should validate_presence_of :delivery_method }

    it { should allow_value('test@example.com').for :email }
    it { should_not allow_value('not_an-email').for :email }

    it { should allow_value('123-654-9871').for :phone_number }
    it { should_not allow_value('135184e6').for :phone_number }

    it { should ensure_inclusion_of(:sales_status).in_array [:pending, :terms_set, :terms_set_and_met, :paid] }

    it 'requires a tax id number if tax_exempt? is true' do
      expect(build(:order, tax_exempt: true)).to_not be_valid
    end
    it 'is valid when tax_exempt? is true and a tax id number is present' do
      expect(build(:order, tax_exempt: true, tax_id_number: 12)).to be_valid
    end

    it 'requires a redo reason if is_redo? is true' do
      expect(build(:order, is_redo: true)).to_not be_valid
    end
    it 'is valid when is_redo? is true and a redo reason is present' do
      expect(build(:order, is_redo: true, redo_reason: 'because')).to be_valid
    end

    it { should ensure_inclusion_of(:delivery_method).in_array(
                            [:pick_up_in_ann_arbor, :pick_up_in_ypsilanti, 
                             :ship_to_one, :ship_to_multiple]) }

  end

  context 'is non-deletable, and' do
    let!(:order) {create(:order)}

    it 'destroyed? returns false when not deleted' do
      expect(order.destroyed?).to eq false
    end
    it 'destroyed? returns true when deleted' do
      order.destroy
      expect(order.destroyed?).to eq true
    end

    it 'still exists after destroy is called' do
      order.destroy
      expect(Order.deleted).to include order
    end
    it 'is not accessible through the default scope once destroyed' do
      order.destroy
      expect(Order.all).to_not include order
    end

    it 'can be revived after being deleted' do
      order.destroy
      expect(order.destroyed?).to eq true
      order.revive
      expect(order.destroyed?).to eq false
    end

  end
end
