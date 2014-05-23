CrmSoftwearcrmCom::Application.routes.draw do

  devise_for :users, controllers: { registrations: 'users/registrations' }, path_names: { sign_up: 'create_user' }

  scope 'configuration' do
    resources :shipping_methods
  end

  root "home#index"

  resources :styles, :brands, :colors, :imprintables, :users

  resources :sizes do
    collection do
      post 'update_size_order'
    end
  end
  
  resources :orders do
    get 'timeline', to: 'timeline#show'
  end

end
