require 'spec_helper'

describe Quote, quote_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:salesperson).class_name('User') }
    it { is_expected.to belong_to(:store) }
    it { is_expected.to have_many(:line_items) }

    it { is_expected.to accept_nested_attributes_for(:line_items) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('test@example.com').for :email }
    it { is_expected.to_not allow_value('not_an-email').for :email }
    it { is_expected.to validate_presence_of(:estimated_delivery_date) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:salesperson) }
    it { is_expected.to validate_presence_of(:store) }
    it { is_expected.to validate_presence_of(:valid_until_date) }
  end

  #TODO implement this
  describe '#all_activities'

  #TODO implement this
  describe '#create_freshdesk_customer'

  describe 'create_freshdesk_ticket', pending: 'Not sure how to test this without actually submitting a ticket' do
  end

  describe 'fetch_data_to_h', pending: 'Does this method need to be spec\'d if it only calls 2 other methods?' do
  end

  describe '#fetch_group_id_and_dept' do
    context 'the quote is from the ann arbor store' do
      let(:quote){ build_stubbed(:blank_quote, store: build_stubbed(:blank_store, name: 'Ann Arbor Store')) }

      it 'sets the group id to "86316" and department to "Sales - Ann Arbor"' do
        return_hash = quote.fetch_group_id_and_dept({})
        expect(return_hash[:group_id]).to eq(86316)
        expect(return_hash[:department]).to eq('Sales - Ann Arbor')
      end
    end

    context 'the quote is from the ypsi store' do
      let(:quote){ build_stubbed(:blank_quote, store: build_stubbed(:blank_store, name: 'Ypsilanti Store')) }

      it 'sets the group_id to "86317" and department to "Sales - Ypsilanti"' do
        return_hash = quote.fetch_group_id_and_dept({})
        expect(return_hash[:group_id]).to eq(86317)
        expect(return_hash[:department]).to eq('Sales - Ypsilanti')
      end
    end

    context 'the quote isn\'t from either store' do
      let(:quote){ build_stubbed(:blank_quote, store: build_stubbed(:blank_store, name: 'Bogus Store')) }

      it 'sets the group_id and department to nil' do
        return_hash = quote.fetch_group_id_and_dept({})
        expect(return_hash[:group_id]).to eq(nil)
        expect(return_hash[:department]).to eq(nil)
      end
    end
  end

  #TODO implement this
  describe '#fetch_request_id_and_name'

  describe 'formatted_phone_number' do
    let(:quote){ build_stubbed(:blank_quote, phone_number: '7342742659') }

    it 'returns the phone number formatted as (xxx) xxx-xxxx' do
      expect(quote.formatted_phone_number).to eq('(734) 274-2659')
    end
  end

  describe 'full_name' do
    let(:quote){ build_stubbed(:blank_quote, first_name: 'First', last_name: 'Last') }

    it 'returns the first name and last name separated by a whitespace' do
      expect(quote.full_name).to eq("#{quote.first_name} #{quote.last_name}")
    end
  end

  #TODO implement this
  describe '#has_line_items?'

  #TODO isn't that slow as is, but could possibly refactor to not use create
  context 'has 2 taxable and 2 non-taxable line items', wip: true do
    let!(:line_item) { create(:non_imprintable_line_item) }
    let!(:quote) { create(:valid_quote) }

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

  #TODO implement this
  describe '#post_request_for_new_customer'

  describe '#standard_line_items' do
    context 'the quote has no line items' do
      let(:quote){ build_stubbed(:blank_quote)}

      it 'returns zero' do
      expect(quote.standard_line_items.size).to eq(0)
      end
    end

    context 'the quote has line items' do
      let(:quote){ create(:valid_quote) }

      it 'returns the number of non-imprintable line items (in this case, two)' do
        expect(quote.standard_line_items.size).to eq(2)
      end
    end
  end

  describe '#tax' do
    let(:quote){ build_stubbed(:blank_quote) }

    it 'returns the value for tax' do
      expect(quote.tax).to eq(0.06)
    end
  end
end