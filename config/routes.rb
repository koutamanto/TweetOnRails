Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    confirmations: "users/confirmations"
  }

  root "home#index"

  get "explore", to: "explore#index"
  get "search", to: "search#index"
  get "bookmarks", to: "bookmarks#index"
  get "notifications", to: "notifications#index"
  post "notifications/mark_all_read", to: "notifications#mark_all_read"

  resources :tweets, only: [:create, :destroy, :show] do
    member do
      post :retweet
      delete :unretweet
    end
    resources :likes, only: [:create, :destroy]
    resources :bookmarks, only: [:create, :destroy]
    resources :replies, only: [:create]
  end

  resources :follows, only: [:create, :destroy]

  resources :conversations, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end

  resources :users, only: [:show], param: :username do
    member do
      get :followers
      get :following
      get :media
      get :likes
    end
  end

  namespace :settings do
    get  'profile', to: 'profile#profile'
    patch 'profile', to: 'profile#update_profile'
    get  'billing', to: 'billing#show'
  end

  get  'pricing', to: 'subscriptions#pricing', as: :pricing
  post 'subscriptions', to: 'subscriptions#create', as: :subscriptions
  get  'subscriptions/success', to: 'subscriptions#success', as: :success_subscriptions
  get  'billing/portal', to: 'subscriptions#portal', as: :billing_portal

  namespace :webhooks do
    post 'stripe', to: 'stripe#receive'
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
