Rails.application.routes.draw do
  get 'settings/connections'
  get 'strava' => 'settings#connections'

  get 'workout/list'
  get '/workout' => 'workout#list'
  get 'workout/finish'
  get 'workout/edit'
  patch 'workout/update'

  get 'dashboard/view'
  get 'dashboard' => 'dashboard#view'

  get '/home' => 'home#index'
  get '/home/index' => 'home#home'

  get 'friend/list'
  get 'friend/add'
  get 'friend/remove'
  get 'friend/confirm'
  get 'friend/remove_follower'

  post 'allset/create'
  get 'allset/destroy'
  patch 'allset/edit'
  patch 'allset/update'

  get 'exercise/edit'
  post 'exercise/create'
  get 'exercise/new'
  get '/exercises' => 'exercise#list'
  get 'exercise/destroy'
  get 'exercise/view'

  get 'users/view'
  get 'users/find'
  get 'feed' => 'feed#view'

  get 'error/permission' => 'application#no_permission'
  get 'error/page_not_found' => 'application#page_not_found'

  devise_for :users, :controllers => {
    registrations: 'registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  resources :exercise, except: [:show] # Use plural 'exercises' for the resource name
  resource :exercise, only: [:show] # Use singular 'exercise' for the resource name

  resources :allset, except: [:update] do
    get 'show', on: :member
    get 'edit', on: :member
    patch '', action: :update, on: :member
  end

  root "home#index"

  #match "*path" => redirect("/"), via: :get


end