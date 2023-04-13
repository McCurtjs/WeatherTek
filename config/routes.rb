Rails.application.routes.draw do
  # For details o the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'forecast#index'

  resources :forecast, param: :query, only: [:index, :show]
  post :search, param: :query, controller: :forecast

end
