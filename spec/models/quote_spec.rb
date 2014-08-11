require 'spec_helper'

describe Quote, quote_spec: true do
  describe 'Relationships' do
    it { should have_many(:line_items) }

    it { should belong_to(:salesperson).class_name('User') }
    it { should belong_to(:store) }
    it { should accept_nested_attributes_for(:line_items) }
  end

  describe 'when validating' do
    it { should validate_presence_of(:store_id) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }

    it { should validate_presence_of(:valid_until_date) }
    it { should validate_presence_of(:estimated_delivery_date) }
    it { should validate_presence_of(:salesperson_id) }

    it { should validate_presence_of(:email) }
    it { should allow_value('test@example.com').for :email }
    it { should_not allow_value('not_an-email').for :email }
  end

  let!(:quote) { create(:valid_quote) }

  describe '#has_line_items?'

  describe '#all_activities'

  describe 'full_name' do
    it 'returns the first name and last name separated by a whitespace' do
      expect(quote.full_name).to eq("#{quote.first_name} #{quote.last_name}")
    end
  end

  context 'has 2 taxable and 2 non-taxable line items' do
    let!(:line_item) { create(:non_imprintable_line_item) }
    before(:each) do
      2.times { quote.line_items << create(:taxable_non_imprintable_line_item) }
    end

    describe '#line_items_subtotal' do
      it 'returns the sum of each line item\'s price' do
        expected_price = line_item.total_price * 4
        expect(quote.line_items_subtotal).to eq(expected_price)
      end
    end

    describe '#line_items_total_tax' do
      it 'returns the sum of the taxable portion of the quote\'s line items' do
        taxable_portion = (line_item.total_price * 2) * 0.06
        expect(quote.line_items_total_tax).to eq(taxable_portion)
      end
    end

    describe '#line_items_total_with_tax' do
      it 'returns the total of the line items, including tax' do
        taxable_portion = (line_item.total_price * 2) * 0.06
        total_price = line_item.total_price * 4
        expect(quote.line_items_total_with_tax).to eq(taxable_portion + total_price)
      end
    end
  end

  describe 'formatted_phone_number' do
    it 'returns the phone number formatted as (xxx) xxx-xxxx' do
      quote.phone_number = '7342742659'
      expect(quote.formatted_phone_number).to eq('(734) 274-2659')
    end
  end

  describe 'standard_line_items' do
    it 'returns both of the line items assigned to the quote' do
      expect(quote.standard_line_items.size).to eq(2)
    end
  end

  describe 'create_freshdesk_ticket', pending: 'Not sure how to test this without actually submitting a ticket' do
  end

  describe 'fetch_data_to_h', pending: 'Does this method need to be spec\'d if it only calls 2 other methods?' do
  end

  describe '#fetch_group_id_and_dept' do
    context 'the quote is from the ann arbor store' do
      before(:each) { quote.store.name = 'Ann Arbor Store' }
      it 'sets the group id to "86316" and department to "Sales - Ann Arbor"' do
        return_hash = quote.fetch_group_id_and_dept({})
        expect(return_hash[:group_id]).to eq(86316)
        expect(return_hash[:department]).to eq('Sales - Ann Arbor')
      end
    end

    context 'the quote is from the ypsi store' do
      before(:each) { quote.store.name = 'Ypsilanti Store' }
      it 'sets the group_id to "86317" and department to "Sales - Ypsilanti"' do
        return_hash = quote.fetch_group_id_and_dept({})
        expect(return_hash[:group_id]).to eq(86317)
        expect(return_hash[:department]).to eq('Sales - Ypsilanti')
      end
    end

    context 'the quote isn\'t from either store' do
      before(:each) { quote.store.name = 'Bogus Store' }
      it 'sets the group_id and department to nil' do
        return_hash = quote.fetch_group_id_and_dept({})
        expect(return_hash[:group_id]).to eq(nil)
        expect(return_hash[:department]).to eq(nil)
      end
    end
  end
end
