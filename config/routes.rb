require 'sidekiq/web'

CrmSoftwearcrmCom::Application.routes.draw do
  mount ActsAsWarnable::Engine => '/'

  root 'home#index'
  get 'home/api_warnings', to: 'home#api_warnings', as: :api_warnings
  get 'home/not_allowed', to: 'home#not_allowed', as: :not_allowed

  get 'imprints/ink_colors', to: 'imprints#ink_colors', as: :imprint_ink_colors
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

  get '/set-session-token', to: 'users#set_session_token', as: :set_session_token

  get 'tags/:tag', to: 'imprintables#index', as: :tag

  resources :brands, :colors
  resources :artworks do
    collection do
      get 'select'
    end
    member do
      get 'full_view'
    end
  end

  resources :artwork_requests do
    member do
      post 'transition(/:state_machine(/:transition))' => :state, as: :transition
    end
  end

  get 'proofing_manager_dashboard', to: 'artwork_requests#manager_dashboard', as: :proofing_manager_dashboard

  resources :prices, only: [:create, :new, :destroy, :index] do
    collection do
      get 'destroy_all'
    end
  end

  resources :quotes, shallow: true do
    member do
      put 'integrate', to: 'quotes#integrate'
    end
    resource :emails

    resources :comments

    collection do
      get 'quote_select'
      post 'stage_quote'
    end
  end
  post 'email/freshdesk', to: 'emails#freshdesk'
  resources :comments
  warning_paths_for :quotes, :orders

  resources :quote_requests do
    get :dock
    post :create_freshdesk_ticket
    resources :emails, :comments

    collection do
      post :filter
    end
  end
  warning_paths_for :quote_requests
  resources :warnings

  scope 'configuration' do
    resources :shipping_methods, :stores, :line_item_templates
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
    resources :platen_hoops
  end

  scope 'administration' do
    resources :coupons do
      collection { get '/validate/:code', to: 'coupons#validate', as: :validate_coupon }
    end
    resources :in_store_credits do
      collection { get :search }
    end
    resources :payment_drops, except: :destroy
  end

  get 'payments/undropped', to: 'payments#undropped'
  resources :payments, :shipments

  resources :orders do
    member do
      get 'production_dashboard', as: 'production_dashboard'
      get :imprintable_order_sheets, as: :imprintable_order_sheets
      get :order_report, as: :order_report
      get 'state/:state_machine' => :state,  as: :state
      post 'transition/(:state_machine/:transition)' => :state, as: :transition
      post :send_to_production
    end

    resources :comments

    collection do
      get 'fba'
      get 'new_fba'
      post 'fba_job_info'
    end

    get 'timeline', to: 'timeline#show', as: :timeline
    resources :payments, :discounts, shallow: true
    resources :artwork_requests
    resources :proofs do
      member do
        post 'transition/(:state_machine/:transition)' => :state, as: :transition
      end

      collection do
        get 'email_customer'
        post 'email_customer'
      end
    end

    resources :jobs, only: [:create, :update, :destroy, :show], shallow: true do
      resources :name_numbers, only: [:create, :destroy]
      member do
        get 'names_numbers', as: :name_number_csv_from
        put :duplicate
      end

      resources :line_items, except: [:update] do
        get :form_partial, on: :member
        post :update_sort_orders
      end
      resources :imprints, except: [:index]
    end
  end

  resources :fba_spreadsheet_uploads
  resources :fba_job_templates do
    collection do
      get :print_locations
    end
  end
  resources :fba_products do
    collection do
      get :variant_fields
      get :new_from_spreadsheet
      post :upload_spreadsheet
    end
  end

  post   'line_items', to: 'line_items#create'
  get    'line_item/select_options', to: 'line_items#select_options'
  put    'line_items/update', to: 'line_items#update'
  patch  'line_items/update', to: 'line_items#update'

  put    'jobs/:job_id/imprints/update', to: 'imprints#update', as: :job_imprints_update
  patch  'jobs/:job_id/imprints/update', to: 'imprints#update'

  namespace 'search' do
    resources :queries
  end
  get '/search', to: 'search/queries#search', as: :search


  resources :sales_reports, only: [:index, :create]
  get '/sales_reports/:report_type/:start_time...:end_time(.:format)', to: 'sales_reports#show', as: :sales_reports_show

  namespace 'api', defaults: { format: :json } do
    match '*path', to: 'api#options', via: :options
    resources 'orders', only: [:index, :show, :update]
    resources 'jobs', only: [:index, :show, :update]
    resources 'imprints', only: [:index, :show, :update]
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

  namespace 'customer' do
    resources :orders, only: [:show, :edit, :update] do
      resources :payments, only: [:index, :new, :create] do
        collection do
          match 'paypal_express', via: [:get, :post]
          match 'paypal_express_success', via: [:get, :post]
        end
      end
    end
  end

end
