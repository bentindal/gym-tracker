# frozen_string_literal: true

Rails.application.routes.draw do
  get 'likes/create'
  get 'likes/destroy'
  get 'settings/connections'
  get 'strava' => 'settings#connections'

  get 'workout/list'
  get '/workout' => 'workout#list'
  get 'workout/finish'
  get 'workout/edit'
  patch 'workout/update'
  get 'workout/view'

  get 'dashboard/view'
  get 'dashboard' => 'dashboard#view'

  get '/home' => 'home#index'
  get '/home/index' => 'home#home'

  get 'friend/list'
  get 'friend/add'
  get 'friend/remove'
  get 'friend/confirm'
  get 'friend/remove_follower'
  post 'friend/unfollow'

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

  # AI Analysis endpoint
  post 'ai/analyze' => 'ai#analyze_workouts'

  get '/service_worker.js' => 'service_worker#service_worker', defaults: { format: 'js' }
  get '/manifest.json' => 'service_worker#manifest', defaults: { format: 'json' }

  get 'error/permission' => 'application#no_permission'
  get 'error/page_not_found' => 'application#page_not_found'

  devise_for :users, controllers: {
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
    member do
      get 'edit'
      patch '', action: :update
    end
  end

  root 'home#index'

  # match "*path" => redirect("/"), via: :get
end
