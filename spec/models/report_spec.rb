require 'spec_helper'

describe Report, report_spec: true, story_82: true do
  let!(:report) { Report.new }

  describe '#quote_request_success' do
    it 'returns the expected values' do
      qrs = 2
      q_from_rs = 3
      o_from_qs = 4
      expect(DateTime).to receive(:strptime).exactly(:twice)
      expect(QuoteRequest).to receive_message_chain(:where, :count).and_return(qrs)
      expect(Quote).to receive_message_chain(:joins, :where, :count).and_return(q_from_rs)
      expect(Order).to receive_message_chain(:joins, :where, :count).and_return(o_from_qs)
      my_hash = report.quote_request_success
      expect(my_hash).to eq({ number_of_quote_requests: qrs,
                              number_of_quotes_from_requests: q_from_rs,
                              number_of_orders_from_quotes: o_from_qs })
    end
  end
end
