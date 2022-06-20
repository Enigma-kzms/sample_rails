Rails.application.routes.draw do
  root 'home#top'
  resources :comment
  get 'comment/confirm'
  post 'comment/confirm'
  get 'comment/excute'
  post 'comment/excute'
  post 'home/create'

  get 'home/signup'
  post 'home/signup'

  get 'home/login'
  post 'home/login'
  post 'home/logout'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
