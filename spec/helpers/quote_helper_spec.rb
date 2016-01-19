require 'spec_helper'

describe QuoteHelper do
  describe '#quantities_and_decoration_prices', story_729: true do
    context "given a quote's imprintable jobs" do
      let!(:job_1) { create(:quote_job, line_items: [create(:imprintable_quote_line_item, decoration_price: 20, quantity: 3)]) }
      let!(:job_2) { create(:quote_job, line_items: [create(:imprintable_quote_line_item, decoration_price: 10, quantity: 5)]) }

      subject { quantities_and_decoration_prices([job_1, job_2]) }

      it 'returns a hash with job ids as keys, and quantity+decoration price objects as values' do
        expect(subject).to eq(
          job_1.id => { quantity: 3, decoration_price: 20 },
          job_2.id => { quantity: 5, decoration_price: 10 }
        )
      end
    end
  end
end
