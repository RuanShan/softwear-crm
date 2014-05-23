CrmSoftwearcrmCom::Application.routes.draw do

  devise_for :users, controllers: { sessions: 'users/sessions' }, skip: 'registration'

  root "home#index"
  
  get '/users/change_password', to: 'users#edit_password', as: :change_password
  put '/users/change_password', to: 'users#update_password', as: :update_password
  get '/users/lock', to: 'users#lock', as: :lock_user

  resources :styles, :brands, :colors, :imprintables, :users
  resources :jobs, only: [:create, :update, :destroy]
  get '/logout' => 'users#logout'
  
  scope 'configuration' do
    resources :shipping_methods
  end

  resources :sizes do
    collection do
      post 'update_size_order'
    end
  end
  
  resources :orders do
    get 'timeline', to: 'timeline#show'
  end

end
