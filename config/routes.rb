Rails.application.routes.draw do


  # all standard, user-facing "resources" go inside this scope
  scope '(:locale)', locale: /en/ do # /en\nl\pl/

    # users and authentication
    resources :users
    get 'user_activate/:activation_code', to: 'user_activations#update',
        as: :user_activation
    resources :user_groups
    get 'sign_in', to: 'user_sessions#new', as: :sign_in
    get 'sign_up', to: 'users#new', as: :sign_up
    resources :user_sessions, only: [:create]
    get 'sign_out', to: 'user_sessions#destroy', as: :sign_out
    get 'profile', to: 'users#show', as: :profile
    post 'change_password', to: 'users#change_password', as: :change_password
    resources :user_password_resets, only: [:new, :edit, :create, :update]
    get 'forgot_password', to: 'user_password_resets#new', as: :forgot_password
    get 'reset_password/:id', to: 'user_password_resets#edit'
    # special routes

    # general resources
    resources :institutions
    resources :qualifications

    # home page
    root 'users#show' # temporary
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
