require 'spec_helper'

describe Order, order_spec: true do
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
    it { should_not allow_value('135184e6').for(:phone_number).with_message("is incorrectly formatted, use 000-000-0000") }

    it { should ensure_inclusion_of(:sales_status).in_array Order::VALID_SALES_STATUSES }

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

    it { should ensure_inclusion_of(:delivery_method).in_array Order::VALID_DELIVERY_METHODS }

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

  context 'relationships' do
    let!(:order) {create :order}

    it 'has a list of line items thorugh its jobs' do
      expect{order.line_items}.to_not raise_error
      expect(order.line_items).to be_a ActiveRecord::Relation
    end

    it 'has a list of imprintables through its jobs' do
      expect{order.imprintables}.to_not raise_error
      expect(order.imprintables).to be_a ActiveRecord::Relation
    end

    it 'has a tax constant that returns 0.6 for now' do
      expect(order.tax).to eq 0.6
    end

    it 'has a subtotal that returns the sum of all its line item prices' do
      expect{order.subtotal}.to_not raise_error
      sum = 0
      order.line_items.each do |line_item|
        sum += line_item.price
      end
      expect(order.subtotal).to eq sum
    end

    it 'has a total that returns the subtotal plus tax' do
      expect{order.total}.to_not raise_error
      expect(order.total).to eq order.subtotal + order.subtotal * order.tax
    end
  end
end
