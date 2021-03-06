Pressfrwrd::Application.routes.draw do
  namespace :admin do
    resources :users, only: [:index]
  end

  resources :users do
    member do
      get :following, :followers
      put :update_admin
    end
  end
  resources :sessions,      only: [:new, :create, :destroy]
  resources :ideas,         only: [:index, :create, :destroy, :new, :show, :edit, :update] do
    member do
      get 'similiar'
    end
    resources :likes, only: [:create, :destroy], shallow:true
  end
  
  resources :join_requests, only: [:create, :update, :show] do
    member do
      put 'accept'
      put 'reject'
    end
  end
  resources :relationships, only: [:create, :destroy]
  root to: 'static_pages#home'

  get '/signup',  to: 'users#new'
  get '/signin',  to: 'sessions#new'
  delete '/signout', to: 'sessions#destroy'
      
  get '/help',    to: 'static_pages#help'
  get '/about',   to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'

  get 'tags/:tag', to: 'ideas#index', as: :tag
end
