Rails.application.routes.draw do

  # Enable /sidekiq for admin users only
  require 'admin_constraint'
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new

  get '404' => redirect('404-page')
  get '500' => redirect('500-page')

  namespace :api do
    get 'penetration_test_start', to: 'penetration_test_webhooks#test_starting'
    get 'penetration_test_finish', to: 'penetration_test_webhooks#test_complete'
    post 'stripe_v01', to: 'stripe_v01#create'
    resources :user_activities, only: :create
  end

  # all standard, user-facing "resources" go inside this scope
  scope '(:locale)', locale: /en/ do # /en\nl\pl/
    get '404' => redirect('404-page')
    get '500' => redirect('500-page')

    # users and authentication
    resources :users
    get 'user_activate/:activation_code', to: 'user_activations#update',
        as: :user_activation
    resources :user_groups
    get 'sign_in', to: 'user_sessions#new', as: :sign_in
    get 'sign_up', to: 'student_sign_ups#new', as: :sign_up
    resources :user_sessions, only: [:create]
    get 'sign_out', to: 'user_sessions#destroy', as: :sign_out
    get 'profile', to: 'users#show', as: :profile
    post 'change_password', to: 'users#change_password', as: :change_password
    resources :user_password_resets, only: [:new, :edit, :create, :update]
    get 'forgot_password', to: 'user_password_resets#new', as: :forgot_password
    get 'reset_password/:id', to: 'user_password_resets#edit'

    # special routes
    get 'personal_sign_up_complete/:id', to: 'student_sign_ups#show', as: :personal_sign_up_complete
    # todo get 'corporate_sign_up_complete', to: 'corporate_dashboard#index', as: :corporate_sign_up_complete
    # todo get 'personal_profile_created', to: 'dashboard#index', as: :personal_profile_created # for corporate users who have converted to personal users
    get 'library(/:subject_area_name_url(/:institution_name_url(/:qualification_name_url(/:exam_level_name_url(/:exam_section_name_url)))))', to: 'library#show', as: :library
    get 'courses/:subject_area_name_url/:institution_name_url/:qualification_name_url/:exam_level_name_url/:exam_section_name_url/:course_module_name_url(/:course_module_element_name_url)', to: 'courses#show', as: :course

    # general resources
    resources :corporate_customers
    resources :countries
    post 'countries/reorder', to: 'countries#reorder'
    resources :courses, only: [:show, :create]
    resources :course_modules
    post 'course_modules/reorder', to: 'course_modules#reorder'
    get 'course_modules/:qualification_url', to: 'course_modules#show',
        as: :course_modules_for_qualification
    get 'course_modules/:qualification_url/:exam_level_url', to: 'course_modules#show',
        as: :course_modules_for_qualification_and_exam_level
    get 'course_modules/:qualification_url/:exam_level_url/:exam_section_url',
        to: 'course_modules#show',
        as: :course_modules_for_qualification_exam_level_and_exam_section
    get 'course_modules/:qualification_url/:exam_level_url/:exam_section_url/:course_module_url',
        to: 'course_modules#show',
        as: :course_modules_for_qualification_exam_level_exam_section_and_name
    post 'course_module_elements/reorder', to: 'course_module_elements#reorder'
    resources :course_module_elements, except: [:index]
    resources :course_module_jumbo_quizzes, only: [:new, :edit, :create, :update]
    post 'currencies/reorder', to: 'currencies#reorder'
    resources :currencies
    get 'dashboard', to: 'dashboard#index', as: :dashboard
    post 'exam_levels/reorder', to: 'exam_levels#reorder'
    get  'exam_levels/filter/:qualification_url', to: 'exam_levels#index', as: :exam_levels_filtered
    post 'exam_levels/filter', to: 'exam_levels#index', as: :exam_levels_filter
    resources :exam_levels
    post 'exam_sections/reorder', to: 'exam_sections#reorder'
    get  'exam_sections/filter/:exam_level_url', to: 'exam_sections#index', as: :exam_sections_filtered
    post 'exam_sections/filter', to: 'exam_sections#index', as: :exam_sections_filter
    resources :exam_sections
    post 'institutions/filter', to: 'institutions#index', as: :institutions_filter
    get  'institutions/filter/:subject_area_url', to: 'institutions#index', as: :institutions_filtered
    post 'institutions/reorder', to: 'institutions#reorder'
    resources :institutions
    resources :invoices, only: [:index, :show]
    post 'qualifications/reorder', to: 'qualifications#reorder'
    get  'qualifications/filter/:institution_url', to: 'qualifications#index',
         as: :qualifications_filtered
    post 'qualifications/filter', to: 'qualifications#index', as: :qualifications_filter
    resources :qualifications
    get 'student_sign_up', to: 'student_sign_ups#new', as: :student_sign_up
    resources :student_sign_ups, only: [:show, :new, :create]
    post 'subject_areas/reorder', to: 'subject_areas#reorder'
    resources :quiz_questions, except: [:index]
    resources :static_pages
    resources :static_page_uploads, only: [:create]

    resources :subject_areas
    resources :subscription_plans
    resources :user_activity_logs
    resources :user_notifications
    resources :vat_codes

    # home page
    root 'static_pages#deliver_page'

    # Catch-all
    get '404', to: 'static_pages#deliver_page', first_element: '404-page'
    get '(:first_element(/:second_element))', to: 'static_pages#deliver_page',
        as: :deliver_static_pages
  end

  # Catch-all
  get '(:first_element(/:second_element))', to: 'static_pages#deliver_page'

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
