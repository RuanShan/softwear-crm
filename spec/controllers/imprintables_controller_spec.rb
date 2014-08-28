require 'spec_helper'

describe ImprintablesController, imprintable_spec: true do
	let!(:valid_user) { create :alternate_user }
  let!(:imprintable) { create(:valid_imprintable) }
  before(:each) { sign_in valid_user }

  describe 'GET index' do
    before(:each) { get :index }

    it 'assigns imprintables' do
      expect(assigns(:imprintables)).to eq([imprintable])
    end

    it 'renders index.html.erb' do
      expect(response).to render_template('imprintables/index')
    end

    context 'there are tags that apply to one imprintable' do
      let!(:imprintable_two) { create(:valid_imprintable, :tag_list => ['comfortable']) }

      it 'only assigns the imprintable with the applicable tag' do
        get :index, tag: ['comfortable']
        expect(assigns(:imprintables)).to eq([imprintable_two])
      end
    end
  end

  describe 'GET new' do
    it 'calls set_model_collection_hash' do
      expect(controller).to receive(:set_model_collection_hash)
      get :new
    end
  end

  describe 'PUT update' do
    context 'with valid input' do
      it 'updates the imprintable' do
        expect { put :update, id: imprintable.to_param, color: { ids: [1] }, size: { ids: [1] }, imprintable: attributes_for(:valid_imprintable) }.to_not change(Imprintable, :count)
        expect(imprintable.special_considerations).to eq('Special Consideration')
      end
    end

    context 'with invalid input' do
      it 'renders edit.html.erb' do
        get :edit, id: imprintable.to_param
        expect(response).to render_template('imprintables/edit')
      end

      it 'it flashes a warning to the user' do
        put :update, id: imprintable.to_param, color: { ids: [40] }, size: { ids: [40] }
        expect(flash[:error]).to eq 'One or more of the imprintable variants could not be created.'
      end
    end
  end

  describe 'GET show' do
    it 'renders show.html.erb' do
      get :show, id: imprintable.to_param
      expect(response).to render_template('imprintables/show')
    end

    it 'renders show when remote is true' do
      get :show, id: imprintable.to_param, remote: true
      expect(response).to render_template('imprintables/show')
    end
  end

  describe 'GET edit' do
    before(:each) { get :edit, id: imprintable.to_param }

    it 'renders edit.html.erb' do
      expect(response).to render_template('imprintables/edit')
    end

    context 'there are no imprintable variants' do
      render_views

      it 'should display variant select partial' do
        expect(response).to render_template(partial: '_variant_select')
      end
    end

    context 'there are imprintable variants' do
      let!(:imprintable_variant) { create(:valid_imprintable_variant) }

      before(:each) {
        imprintable_variant.imprintable_id = imprintable.id
        imprintable_variant.save
      }

      render_views

      it 'should display grid partial' do
        get :edit, id: imprintable.to_param
        expect(response).to render_template(partial: '_grid')
      end
    end
  end

  describe '#update_imprintable_variants' do
    let!(:size) { create(:valid_size) }
    let!(:color) { create(:valid_color) }
    let!(:imprintable_variant) { ImprintableVariant.create(id: 1, imprintable_id: imprintable.id, created_at: Time.now, size_id: size.id, color_id: color.id) }

    context 'when a variant is slated for removal' do
      it 'removes the indicated variant' do
        put :update_imprintable_variants, id: imprintable_variant.imprintable.id.to_param, update: { variants_to_remove: [imprintable_variant.id] }
        expect(ImprintableVariant.exists?(imprintable_variant.id)).to be_falsey
      end
    end

    context 'when an invariant is slated for addition' do
      it 'adds the invariant to the imprintable' do
        expect{ put :update_imprintable_variants, id: imprintable.id.to_param, update: { variants_to_add: [imprintable_variant.id] } }
        expect(imprintable_variant.imprintable).to_not be_nil
        expect(imprintable_variant.imprintable.id).to eq(imprintable.id)
      end
    end

    context 'with invalid data' do
      it 'flashes an error to the user' do
        put :update_imprintable_variants, id: imprintable.to_param, update: { variants_to_add: {'color_id' => 40 } }
        expect(flash[:error]).to eq 'One or more of the variants could not be saved.'
      end
    end
  end

  describe 'protected methods' do
    describe '#set_current_action' do
      it 'sets the current_action to imprintables' do
        controller.send(:set_current_action)
        expect(assigns(:current_action)).to eq 'imprintables'
      end
    end
  end
end
