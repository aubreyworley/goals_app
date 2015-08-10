Rails.application.routes.draw do

  # users routes
  get "/signup", to: "users#new"
  get "/profile", to: "users#show"
  resources :users, only: [:create]

  # sessions routes
  get "/login", to: "sessions#new"
  get "/logout", to: "sessions#destroy"
  # post "/sessions", to: "sessions#create" 
  resources :sessions, only: [:create]


  # goals routes
  resources :goals, except: [:index]

  root "goals#index"
end
