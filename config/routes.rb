Rails.application.routes.draw do
  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"
  # Load subdomain routing helpers
  require_relative '../lib/subdomain_constraint'

  # Health check and monitoring routes (should work across all subdomains)
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Main site routes (no subdomain or www)
  constraints(SubdomainConstraint.new(:main)) do
    get "/analytics" => "analytics#index"
  end

  # Universal root route that works across all subdomains
  root "articles#index"

  # User authentication and management (work across all domains)
  resources :users
  resource :session
  resources :passwords

  # Settings (work across all domains)
  resource :setting, only: [ :edit, :update, :destroy ] do
    collection do
      post :upload
      delete :destroy
    end
  end

  # Admin namespace - 统一所有后台管理功能
  namespace :admin do
    # Admin root now points to articles index
    get "/", to: "articles#index", as: :root

    # Site management
    resources :sites do
      member do
        post :activate
        post :deactivate
      end
    end

    # Content management
    resources :articles, path: "posts" do
      collection do
        get :drafts
        get :scheduled
      end
      member do
        patch :publish
        patch :unpublish
      end
    end

    resources :pages do
      member do
        patch :reorder
      end
    end

    # System management
    resource :newsletter, only: [ :show, :update ], controller: "newsletter"
    resources :exports, only: [ :index, :create ]
    resources :imports, only: [ :index, :create ]
    resources :crossposts, only: [ :index, :update ] do
      member do
        post :verify
      end
    end

    # Jobs and system monitoring
    mount MissionControl::Jobs::Engine, at: "/jobs", as: :jobs
  end

  # Feed and sitemap routes (subdomain-aware)
  get "/rss" => redirect("/feed")
  get "/rss.xml" => redirect("/feed")
  get "/feed.xml" => redirect("/feed")
  get "/feed" => "articles#index", format: "rss", as: :feed
  get "/sitemap.xml" => "sitemap#index", format: "xml", as: :sitemap

  # Public article routes with optional article route prefix
  # These routes work across all subdomains and filter content by current site
  scope path: Rails.application.config.article_route_prefix.presence, as: :articles do
    get "/" => "articles#index", as: :root
    get "/:slug" => "articles#show", as: :article
    get "/:slug/edit" => "articles#edit", as: :edit_article
    post "/" => "articles#create", as: :create_article
    patch "/:slug" => "articles#update", as: :update_article
    delete "/:slug" => "articles#destroy", as: :destroy_article
  end

  # Page routes (subdomain-aware)
  resources :pages, param: :slug

  # Error handling routes
  match "/404", to: "errors#error_404", via: :all
  match "/500", to: "errors#error_500", via: :all
  match "/site_not_found", to: "errors#site_not_found", via: :all

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
