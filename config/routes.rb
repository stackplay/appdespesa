Rails.application.routes.draw do
  get "/up", to: proc { [200, {}, ["ok"]] }
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  namespace :api do
    namespace :v1 do
      post "auth/register"
      post "auth/login"
      post "auth/refresh"
      post "auth/logout"

      resource :profile, only: [:show, :update] do
        patch :password, on: :member
        delete :deactivate, on: :member
      end

      resources :categories, only: [:index, :create, :update, :destroy]
      resources :expenses, only: [:index, :create, :destroy] do
        collection do
          get :export
        end
      end
      resources :tags, only: [:index]
      resources :incomes, only: [:index, :create, :update, :destroy]

      namespace :stats do
        get :overview
        get :monthly
        get :by_category
      end

      namespace :admin do
        resources :expenses, only: [:index]
        resources :audit_logs, only: [:index]
      end
    end
  end
end
