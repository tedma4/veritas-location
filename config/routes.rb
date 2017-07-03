Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :areas, only: [:show, :create, :update, :index, :destroy]
  resources :area_watchers
  resources :area_details
  resources :user_locations, only: [:index]

  get "user_location", to: "area_watchers#user_location"

end
