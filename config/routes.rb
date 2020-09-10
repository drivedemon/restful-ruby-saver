require 'sidekiq/web'

Rails.application.routes.draw do
  # BACKOFFICE ROUTES
  scope '(:locale)', locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :dashboard_users
    devise_scope :dashboard_user do
      authenticated :dashboard_user do
        root 'homepages#index', as: :authenticated_root
      end

      unauthenticated do
        root 'devise/sessions#new', as: :unauthenticated_root
      end
    end
    resources :customers, only: [:index, :export_csv, :show, :destroy, :edit, :update] do
      collection do
        get "request_history/:id", to: "customers#request_history", as: "request_history"
        get "offer_history/:id", to: "customers#offer_history", as: "offer_history"
        get "spending_history/:id", to: "customers#spending_history", as: "spending_history"
        get "earning_history/:id", to: "customers#earning_history", as: "earning_history"
        post "export_csv", to: "customers#export_csv", defaults: { format: :csv }
        post "export_csv_information/:id", to: "customers#export_csv_information", as: "export_csv_information", defaults: { format: :csv }
      end
    end
    resources :homepages, only: [:index]
    resources :dashboard_users
    resources :earning_histories, only: [:index, :export_csv] do
      collection do
        post "export_csv", to: "earning_histories#export_csv", defaults: { format: :csv }
      end
    end
    resources :spending_histories, only: [:index, :export_csv] do
      collection do
        post "export_csv", to: "spending_histories#export_csv", defaults: { format: :csv }
      end
    end
    resources :requests, only: [:index, :export_csv, :show, :destroy] do
      collection do
        post "export_csv", to: "requests#export_csv", defaults: { format: :csv }
        post "export_csv_information/:id", to: "requests#export_csv_information", as: "export_csv_information", defaults: { format: :csv }
      end
    end
    resources :reports, only: [:index, :export_csv, :show] do
      collection do
        post "export_csv", to: "reports#export_csv", defaults: { format: :csv }
        post "export_csv_information/:id", to: "reports#export_csv_information", as: "export_csv_information", defaults: { format: :csv }
      end
    end
    resources :requests_by_location, only: [:index, :export_csv] do
      collection do
        post "export_csv", to: "requests_by_location#export_csv", defaults: { format: :csv }
      end
    end
  end

  # API ROUTES
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
      get "all", to: "sessions#all"
      get "me", to: "sessions#me"
      post "location", to: "sessions#update_user_location"
      post "locale", to: "sessions#set_locale_language"
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
      post "auth/jwt", to: "tokens#validate_token"
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
