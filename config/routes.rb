Rails.application.routes.draw do
  get 'friend/list'
  get 'friend/add'
  get 'friend/remove'

  post 'workout/create'
  get 'workout/destroy'
  patch 'workout/edit'
  patch 'workout/update'


  get 'exercise/edit'
  post 'exercise/create'
  get 'exercise/new'
  get '/exercises' => 'exercise#index'
  get 'exercise/destroy'

  get 'users/view'
  get 'users/find'
  get 'feed' => 'feed#view'

  get 'error/permission' => 'application#no_permission'
  get 'error/page_not_found' => 'application#page_not_found'

  devise_for :users, :controllers => {
    registrations: 'registrations'
  }
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  resources :exercise, except: [:show] # Use plural 'exercises' for the resource name
  resource :exercise, only: [:show] # Use singular 'exercise' for the resource name

  resources :workout, except: [:update] do
    get 'show', on: :member
    get 'edit', on: :member
    patch '', action: :update, on: :member
  end

  root "exercise#index"


end