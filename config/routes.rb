require 'sidekiq/web'

CrmSoftwearcrmCom::Application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }, skip: 'registration'
  mount ActsAsWarnable::Engine => '/'

  root 'home#index'

  get '/users/change_password', to: 'users#edit_password', as: :change_password
  put '/users/change_password', to: 'users#update_password', as: :update_password
  get '/users/lock', to: 'users#lock', as: :lock_user

  get 'imprints/new', to: 'imprints#new', as: :new_imprint

  resources :imprintables do
    collection do
      resources :brands, :colors
      resources :imprintable_groups
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
    member do
      put 'integrate', to: 'quotes#integrate'
    end
    resource :emails do
      collection do
        post 'freshdesk'
      end
    end

    resources :comments

    collection do
      get 'quote_select'
      post 'stage_quote'
    end
  end
  resources :comments
  warning_paths_for :quotes

  resources :quote_requests do
    get :dock
  end
  warning_paths_for :quote_requests

  get '/logout' => 'users#logout'

  scope 'configuration' do
    resources :shipping_methods, :stores
    resources :imprint_methods do
      get '/print_locations', to: 'imprint_methods#print_locations', as: :print_locations
    end
    match 'integrated_crms', to: 'settings#edit', via: :get
    match 'update_integrated_crms', to: 'settings#update', via: :put
    resources :email_templates do
      get '/preview_body', to: 'email_templates#preview_body', as: :preview_body
      collection do
        # TODO: you'll need something like this if you want to expand templates to use more than just quotes
        get '/fetch_table_attributes/(:table_name)', to: 'email_templates#fetch_table_attributes'
      end
    end
  end

  resources :orders do
    member do
      get 'names_numbers', as: :name_number_csv_from
    end

    collection do
      get 'fba'
      get 'new_fba'
      post 'fba_job_info'
    end

    get 'timeline', to: 'timeline#show', as: :timeline
    resources :payments, shallow: true
    resources :artwork_requests
    resources :proofs do
      collection do
        get 'email_customer'
        post 'email_customer'
      end
    end

    resources :jobs, only: [:create, :update, :destroy, :show], shallow: true do
      resources :name_numbers, only: [:create, :destroy]
      member do
        get 'names_numbers', as: :name_number_csv_from
      end

      resources :line_items, except: [:update] do
        get :form_partial, on: :member
      end
      resources :imprints, except: [:index]
    end
  end

  post 'line_items', to: 'line_items#create'
  get '/line_item/select_options', to: 'line_items#select_options'
  put    'line_items/update', to: 'line_items#update'
  patch  'line_items/update', to: 'line_items#update'

  put    'jobs/:job_id/imprints/update', to: 'imprints#update', as: :job_imprints_update
  patch  'jobs/:job_id/imprints/update', to: 'imprints#update'

  namespace 'search' do
    resources :queries
  end
  get '/search', to: 'search/queries#search', as: :search


  resources :sales_reports, only: [:index, :create]
  get '/sales_reports/:report_type/:start_time...:end_time', to: 'sales_reports#show', as: :sales_reports_show

  namespace 'api', defaults: { format: :json } do
    match '*path', to: 'api#options', via: :options
    resources 'orders', only: [:index, :show]
    resources 'jobs', only: [:index, :show]
    resources 'imprints', only: [:index, :show]
    resources 'imprintables'
    resources 'imprintable_variants', only: [:index, :show]
    resources 'colors'
    resources 'sizes'
    resources 'quote_requests', only: [:create, :index, :show]
  end

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '/undock', to: 'home#undock'
  get '/undock/:quote_request_id', to: 'home#undock'

  post '/error-report', to: 'error_reports#email_report'
end
