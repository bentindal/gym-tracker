Rails.application.routes.draw do
  # get 'friend/index'
  get 'friend/list'
  get 'friend/add'
  get 'friend/remove'
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
  get 'feed' => 'feed#view'
  devise_for :users, :controllers => {
    registrations: 'registrations'
  }
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "exercise#index"
end
