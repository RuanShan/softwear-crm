require 'spec_helper'

describe 'shared/_sidebar_menu.html.erb' do
  login_user

  context 'when viewing the dashboard' do
    before(:each) do
      render partial: 'shared/sidebar_menu',
             locals: {
               current_action: 'dashboard',
               current_url: ''
             }
    end

    it 'adds the active class to the "Dashboard" li' do
      expect(rendered).to have_css('li.active a[href="/"] i.fa.fa-home')
    end
  end

  context 'when viewing options under the "Orders" tab' do
    context 'when viewing "List"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'orders#index',
                 current_url: '/orders'
               }
      end

      it 'adds the active class to the Orders li' do
        expect(rendered).to have_css('li.active a i.fa.fa-shopping-cart')
      end

      it 'adds the visible class to the Orders ul and active class to the the List li' do
        expect(rendered).to have_css('li.active ul.visible li.active a[href="/orders"]')
      end
    end

    context 'when viewing "New"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'orders#new',
                 current_url: '/orders/new'
               }
      end

      it 'adds the active class to the Orders li' do
        expect(rendered).to have_css('li.active a i.fa.fa-shopping-cart')
      end

      it 'adds the visible class to the Orders ul and active class to the New li' do
        expect(rendered).to have_css('li.active  ul.visible li.active a[href="/orders/new"]')
      end
    end
  end

  context 'when viewing options under the "Quotes" tab' do
    context 'when viewing "List"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'quotes#index',
                 current_url: '/quotes'
               }
      end

      it 'adds the active class to the Quotes li' do
        expect(rendered).to have_css('li.active a#quotes_list')
      end

      it 'adds the visible class to the Quotes ul and active class to the the List li' do
        expect(rendered).to have_css('li.active ul.visible li.active a#quotes_path_link')
      end
    end

    context 'when viewing "New"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'quotes#new',
                 current_url: '/quotes/new'
               }
      end

      it 'adds the active class to the Quotes li' do
        expect(rendered).to have_css('li.active a#quotes_list')
      end

      it 'adds the visible class to the Quotes ul and active class to the New li' do
        expect(rendered).to have_css('li.active ul.visible li.active a#new_quote_link')
      end
    end
  end

  context 'when viewing options under the "Imprintables" tab' do
    context 'when viewing "List"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'imprintables',
                 current_url: '/imprintables'
               }
      end

      it 'adds the active class to the Imprintables li' do
        expect(rendered).to have_css('li.active a i.fa.fa-archive')
      end

      it 'adds the visible class to Imprintables ul and active class to the List li' do
        expect(rendered).to have_css('li.active ul.visible li.active a#imprintables_list_link')
      end
    end

    context 'when viewing "Brands"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'brands',
                 current_url: '/imprintables/brands'
               }
      end

      it 'adds the active class to the Imprintables li' do
        expect(rendered).to have_css('li.active a i.fa.fa-archive')
      end

      it 'adds the visible class to Imprintables ul and active class to the Brands li' do
        expect(rendered).to have_css('li.active ul.visible li.active a#brands_list_link')
      end
    end

    context 'when viewing "Colors"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'colors',
                 current_url: '/imprintables/colors'
               }
      end

      it 'adds the active class to the Imprintables li' do
        expect(rendered).to have_css('li.active a i.fa.fa-archive')
      end

      it 'adds the visible class to Imprintables ul and active class to the Colors li' do
        expect(rendered).to have_css('li.active ul.visible li.active a#colors_list_link')
      end
    end

    context 'when viewing "Sizes"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'sizes',
                 current_url: '/imprintables/sizes'
               }
      end

      it 'adds the active class to the Imprintables li' do
        expect(rendered).to have_css('li.active a i.fa.fa-archive')
      end

      it 'adds the visible class to Imprintables ul and active class to the Sizes li' do
        expect(rendered).to have_css('li.active ul.visible li.active a#sizes_list_link')
      end
    end
  end

  context 'when viewing options under the "Artwork" tab' do
    context 'when viewing "Artwork Requests"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'artwork_requests',
                 current_url: '/artwork_requests'
               }
      end

      it 'adds the active class to the Artwork li' do
        expect(rendered).to have_css('li.active a i.fa.fa-picture-o')
      end

      it 'adds the visible class to the Artwork ul and active class to the Artwork Requests li' do
        expect(rendered).to have_css('li.active ul.visible a[href="/artwork_requests"]')
      end
    end

    context 'when viewing "Artwork list"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'artworks',
                 current_url: '/artworks'
               }
      end

      it 'adds the active class to the Artwork li' do
        expect(rendered).to have_css('li.active a i.fa.fa-picture-o')
      end

      it 'adds the visible class to the Artwork ul and active class to the Artwork List li' do
        expect(rendered).to have_css('li.active ul.visible li.active a[href="/artworks"]')
      end
    end
  end

  context 'when viewing options under the "Administration" tab' do
    context 'when viewing "Users"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'users',
                 current_url: '/users'
               }
      end

      it 'adds the active class to the "Administration" tab' do
        expect(rendered).to have_css('li.active a i.fa.fa-folder-open')
      end
    end
  end

  context 'when viewing options under the "Configuration" tab' do
    context 'when viewing "Imprint Methods"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'imprint_methods',
                 current_url: '/configuration/imprint_methods'
               }
      end

      it 'adds the active class to the "Configuration" li' do
        expect(rendered).to have_css('li.active a i.fa.fa-gears')
      end

      it 'adds the visible class to the "Configuration" ul and active class to the "Imprint Methods" li' do
        expect(rendered).to have_css('li.active ul.visible li.active a[href="/configuration/imprint_methods"]')
      end
    end

    context 'when viewing "Shipping Methods"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'shipping_methods',
                 current_url: '/configuration/shipping_methods'
               }
      end

      it 'adds the active class to the "Configuration" li' do
        expect(rendered).to have_css('li.active a i.fa.fa-gears')
      end

      it 'adds the visible class to the "Configuration" ul and active class to the "Shipping Methods" li' do
        expect(rendered).to have_css('li.active ul.visible li.active a[href="/configuration/shipping_methods"]')
      end
    end

    context 'when viewing "Stores"' do
      before(:each) do
        render partial: 'shared/sidebar_menu',
               locals: {
                 current_action: 'stores',
                 current_url: '/configuration/stores'
               }
      end

      it 'adds the active class to the "Configuration" li' do
        expect(rendered). to have_css('li.active a i.fa.fa-gears')
      end

      it 'adds the visible class to the "Configuration" ul and active class to the "Stores" li' do
        expect(rendered).to have_css('li.active ul.visible li.active a[href="/configuration/stores"]')
      end
    end
  end
end
