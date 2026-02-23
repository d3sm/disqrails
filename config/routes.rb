Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "latest", to: "posts#index", as: :latest_posts
  resources :posts, only: %i[index show]
  root "posts#index"
end
