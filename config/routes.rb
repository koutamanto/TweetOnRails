Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    confirmations: "users/confirmations"
  }

  root "home#index"
  get "home/new_tweets", to: "home#new_tweets"

  post   "push_subscriptions",         to: "push_subscriptions#create"
  delete "push_subscriptions",         to: "push_subscriptions#destroy"

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

  # Creator tools
  namespace :creator do
    get  'setup',           to: 'onboarding#setup',          as: :setup
    post 'setup',           to: 'onboarding#create_account', as: :create_account
    get  'stripe/connect',  to: 'onboarding#stripe_connect', as: :stripe_connect
    get  'stripe/return',   to: 'onboarding#stripe_return',  as: :stripe_return
    get  'stripe/refresh',  to: 'onboarding#stripe_refresh', as: :stripe_refresh
    get  'dashboard',       to: 'dashboard#show',            as: :dashboard
    resources :posts, controller: 'premium_posts',           as: :posts
    get  'earnings',        to: 'earnings#show',             as: :earnings
    get  'payout',          to: 'payout_settings#show',      as: :payout
    patch 'payout',         to: 'payout_settings#update',    as: :update_payout
  end

  # Public creator profile
  get 'creators/:username', to: 'creator_profiles#show', as: :creator_profile

  # Premium posts (public view)
  resources :premium_posts, only: [:show]

  # Fan subscriptions
  resources :fan_subscriptions, only: [:create, :destroy] do
    collection { get :success }
  end

  # PPV purchases
  resources :premium_purchases, only: [:create] do
    collection { get :success }
  end

  namespace :webhooks do
    post 'stripe', to: 'stripe#receive'
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
