Api::Engine.routes.draw do
  resources :imprintables, only: [:index, :show]
end
