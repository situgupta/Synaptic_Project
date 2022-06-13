Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end
  
  devise_for :users, controllers:{
    registrations: 'users/registrations',
    sessions:'users/sessions',
    omniauth_callbacks:'users/omniauth_callbacks'
  }

  namespace :api do
    resources :user_register, only: %i[create]
    resources :user_csv_record do
      collection {post :import
                  post :export}
    end
    resources :data_aggregation do
    collection {get :fetch_aggregation_result
                post :share_result
                }
    end
  end
end
