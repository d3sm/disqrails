Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/login", to: "sessions#new", as: :login
  delete "/logout", to: "sessions#destroy", as: :logout
  match "/auth/:provider/callback", to: "sessions#create", via: [:get, :post]
  match "/auth/failure", to: "sessions#failure", via: [:get, :post]

  get "/u/:id", to: "profiles#show", as: :user_profile
  delete "/u/:id", to: "profiles#destroy"

  resources :feeds, only: [:index, :create]
  resources :subscriptions, only: [:create, :destroy]

  get "latest", to: "posts#index", as: :latest_posts
  post "posts/refresh", to: "posts#refresh", as: :refresh_posts
  resources :posts, only: [:index, :show] do
    resources :comments, only: [:create]
    get :load_external_comments, on: :member
    resource :reaction, only: [:create], controller: "reactions"
  end
  resources :comments, only: [] do
    resource :reaction, only: [:create], controller: "reactions"
  end
  root "posts#index"
end
