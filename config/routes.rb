Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }
  
  root "store#index"

  get "/store",          to: "store#index",  as: :store
  get "/store/:id",      to: "store#show",   as: :store_product
  get  "/store/:id/checkout",       to: "store#checkout", as: :checkout
  post "/store/:id/checkout",       to: "store#process_checkout"
  get  "/store/:id/confirmation",   to: "store#confirmation", as: :confirmation

  get "/health", to: "store#health"
end



