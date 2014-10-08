shared_examples 'retailable' do
  describe 'Validations' do
    context "if retail" do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(true)}
      it { should validate_presence_of(:sku) }

      # TODO: For some reason, shoulda_matcher would break if in this context
      context 'it validates uniqueness of sku' do
        let(:color) { create(:valid_color) }
        it { should_not allow_value(color.sku).for(:sku)}
      end

    end

    context "if not retail" do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(false)}
      it { should_not validate_presence_of(:sku) }
      it { should_not validate_uniqueness_of(:sku) }
    end


    describe '#is_retail?' do
      context 'retail is true' do
        before { allow(subject).to receive_message_chain(:retail).and_return(true)}
        it 'returns true' do
          expect(subject.is_retail?).to be_truthy
        end
      end
      context 'retail is false' do
        before { allow(subject).to receive_message_chain(:retail).and_return(false)}
        it 'returns false' do
          expect(subject.is_retail?).to be_falsey
        end
      end
    end

  end
end

shared_examples 'a retailable api controller' do
  resource_name = described_class.controller_name.singularize
  resource_type = Kernel.const_get(
      described_class.controller_name.singularize.camelize
    )

  describe 'GET #index' do
    it "assigns @#{resource_name.pluralize} where retail: true" do
      allow(resource_type).to receive(:where).and_call_original
      expect(resource_type).to receive(:where)
        .with(hash_including retail: true)
        .and_call_original

      get 'index', format: :json
    end
  end
end
