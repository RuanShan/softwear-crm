require 'spec_helper'

describe OrderHelper, order_spec: true do
  describe '#get_style_from_invoice_state' do
    let!(:order) { (build_stubbed(:blank_order)) }

    context 'invoice_state is approved' do
      before(:each) do
        allow(order).to receive(:invoice_state).and_return('approved')
      end

      it 'returns label-danger' do
        expect(get_style_from_invoice_state(order.invoice_state)).to eq('label-success')
      end
    end

    context 'invoice_state is pending' do
      before(:each) do
        allow(order).to receive(:invoice_state).and_return('pending')
      end

      it 'returns label-danger' do
        expect(get_style_from_invoice_state(order.invoice_state)).to eq('label-warning')
      end
    end
  end


  describe '#get_style_from_status' do
    let!(:order) { (build_stubbed(:blank_order)) }

    context 'Payment Terms Pending' do
      before(:each) do
        allow(order).to receive(:payment_status).and_return('Payment Terms Pending')
      end

      it 'returns label-danger' do
        expect(get_style_from_status(order.payment_status)).to eq('label-danger')
      end
    end

    context 'Awaiting Payment' do
      before(:each) do
        allow(order).to receive(:payment_status).and_return('Awaiting Payment')
      end

      it 'returns label-danger' do
        expect(get_style_from_status(order.payment_status)).to eq('label-danger')
      end
    end

    context 'Payment Terms Met' do
      before(:each) do
        allow(order).to receive(:payment_status).and_return('Payment Terms Met')
      end

      it 'returns label-warning' do
        expect(get_style_from_status(order.payment_status)).to eq('label-warning')
      end
    end

    context 'Payment Complete' do
      before(:each) do
        allow(order).to receive(:payment_status).and_return('Payment Complete')
      end

      it 'returns label-success' do
        expect(get_style_from_status(order.payment_status)).to eq('label-success')
      end
    end
  end
end
