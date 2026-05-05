Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  namespace :api do
    namespace :v1 do
      get "incomes/index"
      get "incomes/create"
      get "incomes/update"
      get "incomes/destroy"
      post "auth/register"
      post "auth/login"
      post "auth/refresh"
      post "auth/logout"
      
      resources :incomes, only: [:index, :create, :update, :destroy]
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