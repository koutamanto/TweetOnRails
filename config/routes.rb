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
    get :profile
    patch :profile, action: :update_profile
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
