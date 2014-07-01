require 'spec_helper'

describe ImprintablesController, imprintable_spec: true do
	let!(:valid_user) { create :alternate_user }
  let!(:imprintable) { create(:valid_imprintable) }
  before(:each) { sign_in valid_user }

  describe 'GET index' do

    it 'assigns imprintables' do
      get :index
      expect(assigns(:imprintables)).to eq([imprintable])
    end

    it 'renders index.html.erb' do
      get :index
      expect(response).to render_template('imprintables/index')
    end
  end

  describe 'GET show', new: true do
    it 'renders show.html.erb' do
      get :show, id: imprintable.to_param
      expect(response).to render_template('imprintables/show')
    end
  end

  describe 'GET edit' do
    it 'renders edit.html.erb' do
      get :edit, id: imprintable.to_param
      expect(response).to render_template('imprintables/edit')
    end

    context 'there are no imprintable variants' do
      render_views
      it 'should display variant select partial' do
        get :edit, id: imprintable.to_param
        expect(response).to render_template(:partial => '_variant_select')
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
        expect(response).to render_template(:partial => '_grid')
      end
    end
  end

  describe 'PUT update' do
    context 'with valid input' do
      it 'updates the imprintable' do
        expect{ put :update, id: imprintable.to_param, color_ids: [1], size_ids: [1], imprintable: attributes_for(:valid_imprintable) }.to_not change(Imprintable, :count)
        expect(imprintable.special_considerations).to eq('Special Consideration')
      end
    end

    context 'with invalid input' do
      it 'renders edit.html.erb' do
        get :edit, id: imprintable.to_param
        expect(response).to render_template('imprintables/edit')
      end
    end
  end

  describe 'POST create' do
    context 'with valid input' do
      it 'creates a new imprintable' do
        expect{post :create, order: create(:order_with_job), imprintable: create(:valid_imprintable)}.to change(Imprintable, :count).by(1)
        expect(imprintable.special_considerations).to eq('Special Consideration')
      end
    end

    context 'with invalid input' do
      it 'renders new.html.erb' do
        get :new
        expect(response).to render_template('imprintables/new')
      end
    end
  end

  describe 'update_imprintable_variants' do
    let!(:size) { create(:valid_size) }
    let!(:color) { create(:valid_color) }
    let!(:imprintable_variant) { ImprintableVariant.create(id: 1, imprintable_id: imprintable.id, created_at: Time.now, size_id: size.id, color_id: color.id) }

    context 'an invariant is slated for removal' do
      it 'removes the indicated invariant' do
        put :update_imprintable_variants, id: imprintable_variant.imprintable.id.to_param, update: { variants_to_remove: [imprintable_variant.id] }
        expect(ImprintableVariant.exists?(imprintable_variant.id)).to be_falsey
      end
    end

    context 'an invariant is slated for addition' do
      it 'adds the invariant to the imprintable' do
        expect{ put :update_imprintable_variants, id: imprintable.id.to_param, update: { variants_to_add: [imprintable_variant.id] } }
        expect(imprintable_variant.imprintable).to_not be_nil
        expect(imprintable_variant.imprintable.id).to eq(imprintable.id)
      end
    end
  end
end
