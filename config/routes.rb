Rails.application.routes.draw do
  get 'bases/new'

  resources :tasks
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
 
  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'working_list'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
    end
    collection {post :import}
    resources :attendances, only: :update
  end
  resources :bases do
  end
end
