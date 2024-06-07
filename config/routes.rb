Rails.application.routes.draw do
  
  get "up" => "rails/health#show", as: :rails_health_check

  root 'static_pages#top'
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'terms_of_use', to: 'static_pages#terms_of_use'

  get 'login', to: 'user_sessions#new' , as: :login
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy', as: :logout

  resources :users, only: [:new, :create, :show, :edit, :update]

  resources :items

  resources :send_lists

end
