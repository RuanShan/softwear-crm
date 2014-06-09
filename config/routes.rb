CrmSoftwearcrmCom::Application.routes.draw do

  devise_for :users, controllers: { sessions: 'users/sessions' }, skip: 'registration'

  root "home#index"
  
  get '/users/change_password', to: 'users#edit_password', as: :change_password
  put '/users/change_password', to: 'users#update_password', as: :update_password
  get '/users/lock', to: 'users#lock', as: :lock_user

  resources :users

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
  resources :jobs, only: [:create, :update, :destroy]

  get '/logout' => 'users#logout'
  
  scope 'configuration' do
    resources :shipping_methods, :stores
    resources :imprint_methods
  end
  
  resources :orders do
    get 'timeline', to: 'timeline#show'
  end

end
