CrmSoftwearcrmCom::Application.routes.draw do

  devise_for :users, controllers: { sessions: 'users/sessions' }, skip: 'registration'

  root "home#index"
  
  get '/users/change_password', to: 'users#edit_password', as: :change_password
  put '/users/change_password', to: 'users#update_password', as: :update_password
  get '/users/lock', to: 'users#lock', as: :lock_user

  resources :imprintables do
    collection do
      resources :styles, :brands, :colors

      resources :sizes do
        collection do
          post 'update_size_order'
        end
        get '/imprintables/assets' => redirect('/assets')
      end
    end
  end

  resources :styles, :brands, :colors, :users

  get '/logout' => 'users#logout'
  
  scope 'configuration' do
    resources :shipping_methods, :stores
  end
  
  resources :orders, shallow: true do
    get 'timeline', to: 'timeline#show'
    resources :jobs, only: [:create, :update, :destroy, :show] do
      resources :line_items
    end
  end

end
