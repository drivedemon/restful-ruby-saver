require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :api do
    namespace :list do
      resources :professions, only: :index
    end

    namespace :vipps do
      resources :sessions, only: [:index, :payment, :capture] do
        collection do
          get "/", to: "sessions#index"
          get "payment", to: "sessions#payment"
          get "capture", to: "sessions#capture"
        end
      end
    end

    namespace :user do
      get "me", to: "sessions#me"
      post "sign_in", to: "sessions#sign_in"
      post "sign_up", to: "sessions#sign_up"
      delete "sign_out", to: "sessions#sign_out"
      delete "gdpr/remove", to: "sessions#remove"

      match "profile", to: "sessions#update_profile", via: [:put, :patch]

      resources :conversations, only: :index
      resources :histories, only: :index

      resources :notification, only: [:reset, :clear], :controller => "notification_setting" do
        collection do
          match "clear", via: [:put, :patch]
          match "reset", via: [:put, :patch]
          match "/", to: "notification_setting#update", via: [:put, :patch]
        end
      end
    end

    namespace :validate do
      resources :urgents, only: :index
    end

    # mount Sidekiq::Web, at: '/sidekiq'

    post '/presigned_url', to: 'direct_upload#create'

    resources :chats
    resources :chat_rooms, only: [:create, :show]
    resources :help_requests
    resources :feedbacks, only: [:create]
    resources :notifications , only: [:index, :update], :controller => "notification_views" do
      collection do
        delete "/", to: "notification_views#destroy", via: :delete
      end
    end
    resources :offer_requests
    resources :rating , only: [:create, :show]
    resources :reports , only: [:index, :create]
  end
end
