CrmSoftwearcrmCom::Application.routes.draw do

  devise_for :users, controllers: { sessions: 'users/sessions' }, skip: 'registration'

  root "home#index"
  
  get '/users/change_password', to: 'users#edit_password', as: :change_password
  put '/users/change_password', to: 'users#update_password', as: :update_password
  get '/users/lock', to: 'users#lock', as: :lock_user

  resources :imprintables do
    collection do
      resources :brands, :colors
      post 'update_imprintable_variants'

      resources :sizes do
        collection do
          post 'update_size_order'
        end
      end
    end
  end

  get 'tags/:tag', to: 'imprintables#index', as: :tag

  resources :brands, :colors, :users, :artwork_requests, :artworks
  resources :prices, only: [:create, :new, :destroy, :index] do
    collection do
      get 'destroy_all'
    end
  end

  resources :quotes, shallow: true do
    post 'email_customer'
    collection do
      get 'quote_select'
      post 'stage_quote'
    end
    resources :line_items
  end

  get '/logout' => 'users#logout'
  
  scope 'configuration' do
    resources :shipping_methods, :stores
    resources :imprint_methods do
      get '/print_locations', to: 'imprint_methods#print_locations', as: :print_locations
    end
  end
  
  resources :orders do
    get 'timeline', to: 'timeline#show', as: :timeline
    resources :payments, shallow: true
    resources :artwork_requests
    resources :jobs, only: [:create, :update, :destroy, :show], shallow: true do
      resources :line_items do
        get :form_partial, on: :member
      end
      resources :imprints, except: [:index]
    end
  end
  get '/line_item/select_options', to: 'line_items#select_options'
  delete '/line_items/*ids', to: 'line_items#destroy'

  namespace 'search' do
    resources :queries
  end
  get '/search', to: 'search/queries#search', as: :search

  mount Api::Engine => "/api"

end
