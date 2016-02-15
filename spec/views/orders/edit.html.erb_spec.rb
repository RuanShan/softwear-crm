require 'spec_helper'

describe 'orders/edit.html.erb', order_spec: true do
  login_user

  let!(:order) { create(:order) }
  before(:each) { assign :order, order}

  it 'displays the order name and ID' do
    params[:id] = order.id
    render
    expect(rendered).to have_css 'h1', text: "Order ##{order.id}"
    expect(rendered).to have_css 'h2', text: order.name
  end

  it 'has a link to "Order Report"  on the top right' do
    render
    expect(rendered).to have_link('Order Report')
  end

  it 'displays the jobs tab by default' do 
    render
    expect(rendered).to have_css("li.active", text: 'Jobs')
    expect(rendered).to have_css("#jobs.active")  
  end

  context 'when imported_from_admin' do
    let!(:admin_proof) { create(:admin_proof, order: order) }

    before do
      order.imported_from_admin = true
    end

    it 'should give a warning on artwork tab' do
      render
      expect(rendered).to have_content("This order is an ancient relic")
    end

    it 'should display the admin_proofs' do
      render
      expect(rendered).to have_content admin_proof.name
      expect(rendered).to have_content admin_proof.description
      expect(rendered).to have_css "img[src='#{admin_proof.thumbnail_url}']"
      expect(rendered).to have_css "a[href='#{admin_proof.file_url}']"
    end

    context 'when a proof has no thumbnail' do
      let!(:proof_without_thumbnail) { create(:admin_proof, order: order, thumbnail_url: '') }

      it 'provides a link with the text "View full image" instead of the thumbnail link' do
        render
        expect(rendered).to have_css "a[href='#{admin_proof.file_url}']", text: 'View full image'
      end
    end
  end

  context 'when not imported_from_admin' do
    it 'display the artwork' do
      render
      expect(rendered).to_not have_content("This order is an ancient relic")
    end
  end
end
