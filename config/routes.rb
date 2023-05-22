Rails.application.routes.draw do
  devise_for :users
  get 'workout/show'
  get 'workout/create'
  get 'workout/destroy'
  get 'exercise/create'
  get 'exercise/new'
  get '/exercises' => 'exercise#index'
  get 'exercise/create'
  get 'exercise/destroy'
  get 'home/index'
  get 'users/view'
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "exercise#index"
end
