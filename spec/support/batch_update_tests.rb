shared_examples 'batch update' do
  describe '#batch_update', batch_update_spec: true do
    let!(:resource_name) { described_class.controller_name.singularize.to_sym }
    let!(:dummy_class) do
      Struct.new(:test_attr, :id) do
        alias_method :serializable_hash, :to_h

        def self.columns_hash
          {}
        end

        def save
        end
      end
    end
    let!(:resource_class) { subject.send(:resource_class) }
    before do
      allow(resource_class).to receive(:unscoped).and_return resource_class
      allow(resource_class).to receive(:insert).and_return nil
    end

    let!(:params) do
      {
        resource_name => {
          '1' => { test_attr: 'test_1' },
          '2' => { test_attr: 'test_2' }
        }
      }
    end

    before do
      allow(params).to receive_message_chain(:permit, :permit!)
      allow(subject).to receive(:params) { params }
    end

    it 'should update resources from the params format resource[id[val]]' do
      dummy_1 = dummy_class.new('unaltered', 1)
      dummy_2 = dummy_class.new('unaltered', 2)

      [dummy_1, dummy_2].each do |dummy|
        allow(dummy).to receive(:changed?).and_return true
      end

      allow(resource_class).to receive(:find).with('1') { dummy_1 }
      allow(resource_class).to receive(:find).with('2') { dummy_2 } 

      subject.send(:batch_update)

      expect(dummy_1.test_attr).to eq 'test_1'
      expect(dummy_2.test_attr).to eq 'test_2'
    end

    it 'should not update resources with attributes matching the params' do
      dummy_1 = dummy_class.new('test_1', 1)
      dummy_2 = dummy_class.new('test_2', 2)

      [dummy_1, dummy_2].each do |dummy|
        allow(dummy).to receive(:changed?).and_return false
      end

      allow(resource_class).to receive(:find).with('1') { dummy_1 }
      allow(resource_class).to receive(:find).with('2') { dummy_2 }

      expect(dummy_1).to_not receive(:save)
      expect(dummy_2).to_not receive(:save)

      subject.send(:batch_update)
    end

    describe 'options' do
      describe 'assignment:' do
        context '<valid proc>' do
          let(:assignment_proc) do
            proc do |record, attrs|
              record.test_attr = "test_attr #{attrs[:test_attr]}"
            end
          end

          it 'calls the given proc instead of the default assignment' do
            dummy_1 = dummy_class.new('test_1', 1)
            dummy_2 = dummy_class.new('test_2', 2)

            [dummy_1, dummy_2].each do |dummy|
              allow(dummy).to receive(:changed?).and_return false
            end

            allow(resource_class).to receive(:find).with('1') { dummy_1 }
            allow(resource_class).to receive(:find).with('2') { dummy_2 }

            subject.send(:batch_update, assignment: assignment_proc)

            expect(dummy_1.test_attr).to eq 'test_attr test_1'
            expect(dummy_2.test_attr).to eq 'test_attr test_2'
          end
        end

        context '<non-proc>' do
          let(:bad_arg) { "I am a string. Not very proc-like, huh." }
          
          it 'raises an error' do
            dummy = double(resource_class.name)
            allow(resource_class).to receive(:find).and_return dummy
            allow(dummy).to receive(:id).and_return 1

            expect do
              subject.send(:batch_update, assignment: bad_arg)
            end
              .to raise_error BatchUpdateError
          end
        end
      end

      describe 'create_negatives:' do
        context 'true' do
          let(:params) do
            {
              resource_name => {
                '-1' => { test_attr: 'test_1' },
                '-2' => { test_attr: 'test_2' }
              }
            }
          end

          before do
            allow_any_instance_of(resource_class).to receive(:test_attr=)
            allow(params).to receive_message_chain(:permit, :permit!)
            allow(subject).to receive(:params) { params }
          end

          it 'should create resources for negative ids in the params hash' do
            test_record = double(resource_class.name)
            allow(test_record).to receive(:save)
            expect(resource_class).to receive(:new)
              .and_return(test_record).twice

            expect(test_record).to receive(:test_attr=).with('test_1')
            expect(test_record).to receive(:test_attr=).with('test_2')

            subject.send(:batch_update, create_negatives: true)
          end

          it 'should not attempt to find records with negative ids' do
            expect(resource_class).to_not receive(:find)

            subject.send(:batch_update, create_negatives: true)
          end

          context 'with parent: <parent record>' do
            let!(:parent) { Struct.new(:id).new(5) }

            before do
              allow(parent)
                .to receive_message_chain(:class, :name, :underscore)
                .and_return 'test_class'
            end

            it 'should assign the parent record id to the new records' do
              test_record = double(resource_class.name)
              allow(test_record).to receive(:save)
              expect(resource_class).to receive(:new)
                .and_return(test_record).twice

              allow(test_record).to receive(:test_attr=)
              expect(test_record).to receive(:test_class_id=).with(5).twice

              subject.send(
                :batch_update,
                create_negatives: true, parent: parent
              )
            end
          end
        end
      end
    end
  end
end
