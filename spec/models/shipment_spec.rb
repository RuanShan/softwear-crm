require 'spec_helper'

describe Shipment do
  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :city }
    it { is_expected.to validate_presence_of :state }
    it { is_expected.to validate_presence_of :address_1 }
    it { is_expected.to validate_presence_of :zipcode }
    it { is_expected.to validate_presence_of :time_in_transit }
    it { is_expected.to validate_numericality_of(:time_in_transit).is_greater_than(0) }
  end

  describe '#status' do
    context 'on creation' do
      it 'is set to "pending"', story_860: true do
        expect(create(:shipment).status).to eq 'pending'
      end

      context 'when a tracking number is provided', story_860: true do
        it 'is set to "shipped"' do
          expect(create(:shipment, tracking_number: '123').status).to eq 'shipped'
        end
      end
    end
  end

  describe '#tracking_url' do
    let(:shipment_with_number) { create(:shipment_with_tracking_number_shipping_url) } 
    let(:shipment) { create(:shipment) }

    context 'shipping_method tracking_url contains :tracking_number' do
      it 'should replace the :tracking_number in the url with shipments tracking_number' do
        expect(shipment_with_number.tracking_url).to eq("http://www.tracking-site.com/#{shipment_with_number.tracking_number}") 
      end
    end

    context 'shipping_method tracking_url doesn\'t contain :tracking_number' do
      it 'should just return the shipping_method tracking_url' do
        expect(shipment.tracking_url).to eq(shipment.shipping_method.tracking_url)
      end
    end 
  end

  describe 'when status gets changed to shipped', story_1076: true do
    subject { create(:shipment) }

    it 'has its order update notification state' do
      expect(subject.shippable.notification_state).to_not eq 'shipped'
      subject.tracking_number = 'tracking'
      subject.save!
      expect(subject.shippable.reload.notification_state).to eq 'shipped'
    end
  end

  describe '#create_train', create_train: true do
    subject { build(:shipment, shippable: create(:order_with_job)) }

    context 'when the order is in production' do
      before(:each) do
        subject.save!
        subject.shippable.update_column :softwear_prod_id, 1
      end

      context 'and the shipment is of shipping method "Ann Arbor Tees Delivery"' do
        before(:each) do
          subject.shipping_method.name = 'Ann Arbor Tees Delivery'
          subject.shipping_method.save!
        end

        context 'when state is shipped' do
          it 'creates a LocalDeliveryTrain at the "out_for_delivery" state' do
            subject.status = 'shipped'

            expect(Production::LocalDeliveryTrain).to receive(:create)
              .with(hash_including(softwear_crm_id: subject.id, order_id: 1, state: 'out_for_delivery'))
              .and_return double('LocalDeliveryTrain', persisted?: true, id: 1)

            subject.create_train
          end
        end

        context 'when state is not shipped' do
          it 'creates a LocalDeliveryTrain at the "pending_packing" state' do
            subject.status = 'pending'

            expect(Production::LocalDeliveryTrain).to receive(:create)
              .with(hash_including(softwear_crm_id: subject.id, order_id: 1, state: 'pending_packing'))
              .and_return double('LocalDeliveryTrain', persisted?: true, id: 1)

            subject.create_train
          end
        end

        context 'when the train fails to create', train_fail: true do
          it 'issues a warning' do
            allow(Production::LocalDeliveryTrain).to receive(:create)
              .with(anything)
              .and_return double(
                'LocalDeliveryTrain (error)', persisted?: false,
                errors: double('errors', full_messages: ['I just', "can't do it"])
              )

            expect(subject.shippable).to receive(:issue_warning)
              .with('Production API', "Failed to create RSpec::Mocks::Double: I just, can't do it")

            subject.create_train
          end
        end
      end

      context 'and the shipment is of a shipping method other than "Ann Arbor Tees Delivery"' do
        it 'creates a ShipmentTrain' do
          expect(Production::ShipmentTrain).to receive(:create)
            .with(
              hash_including(
                softwear_crm_id: subject.id,
                shipment_holder_type: 'Order',
                shipment_holder_id: subject.order.id,
                state: anything
              )
            )
            .and_return double("ShipmentTrain", persisted?: true, id: 1)

          subject.create_train
        end
      end
    end

    context 'when the shipment is created into an order that is not in production' do
      it 'does not get called' do
        expect(subject).to_not receive(:create_train)
        subject.save!
      end
    end

    context 'when the shipment is created into an order that is in production' do
      it 'gets called' do
        allow(subject.order).to receive(:production?).and_return true
        expect(subject).to receive(:create_train)
        subject.save!
      end
    end
  end
end
