Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :areas
  resources :area_watchers
  resources :area_details

end
