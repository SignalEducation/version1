Rails.application.routes.draw do

  concern :supports_reordering do
    post :reorder, on: :collection
  end

  # Enable /sidekiq for admin users only
  require 'admin_constraint'
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new

  get '404' => redirect('404-page')
  get '500' => redirect('500-page')

  namespace :api do
    get 'penetration_test_start', to: 'penetration_test_webhooks#test_starting'
    get 'penetration_test_finish', to: 'penetration_test_webhooks#test_complete'
    post 'stripe_v01', to: 'stripe_v01#create'
    post 'stripe_dev/:dev_name', to: 'stripe_dev#create'
    resources :user_activities, only: :create
  end

  # unscoped routes - to support incoming traffic from v2 cached pages
  get '/courses/:subject_area_name_url',
      to: redirect('/en/library/%{subject_area_name_url}')
  get '/courses/:subject_area_name_url/:institution_name_url',
      to: redirect('/en/library/%{subject_area_name_url}/%{institution_name_url}')
  get '/courses/:subject_area_name_url/:institution_name_url/:qualification_name_url',
      to: redirect('/en/library/%{subject_area_name_url}/%{institution_name_url}/%{qualification_name_url}')
  get '/courses/:subject_area_name_url/:institution_name_url/:qualification_name_url/:exam_level_name_url',
      to: redirect('/en/library/%{subject_area_name_url}/%{institution_name_url}/%{qualification_name_url}/%{exam_level_name_url}')
  get '/courses/:subject_area_name_url/:institution_name_url/:qualification_name_url/:exam_level_name_url/:exam_section_name_url',
      to: redirect('/en/library/%{subject_area_name_url}/%{institution_name_url}/%{qualification_name_url}/%{exam_level_name_url}/%{exam_section_name_url}')

  # all standard, user-facing "resources" go inside this scope
  scope '(:locale)', locale: /en/ do # /en\nl\pl/
    get '404' => redirect('404-page')
    get '500' => redirect('500-page')

    # users and authentication
    resources :users do
      get 'new_paid_subscription', to: 'users#new_paid_subscription', as: :new_paid_subscription
      patch 'upgrade_from_free_trial', to: 'users#upgrade_from_free_trial', as: :upgrade_from_free_trial
    end

    get 'user_activate/:activation_code', to: 'user_activations#update',
        as: :user_activation
    resources :user_groups
    get 'sign_in', to: 'user_sessions#new', as: :sign_in
    resources :user_sessions, only: [:create]
    get 'sign_out', to: 'user_sessions#destroy', as: :sign_out
    get 'profile', to: 'users#show', as: :profile
    post 'change_password', to: 'users#change_password', as: :change_password
    resources :user_password_resets, only: [:new, :edit, :create, :update]
    get 'forgot_password', to: 'user_password_resets#new', as: :forgot_password
    get 'reset_password/:id', to: 'user_password_resets#edit', as: :reset_password

    # special routes
    get 'personal_sign_up_complete', to: 'student_sign_ups#show', as: :personal_sign_up_complete
    # todo get 'corporate_sign_up_complete', to: 'corporate_dashboard#index', as: :corporate_sign_up_complete
    # todo get 'personal_profile_created', to: 'dashboard#index', as: :personal_profile_created # for corporate users who have converted to personal users


    get 'courses/:exam_level_name_url(/:exam_section_name_url)/question_bank/:id', to: 'courses#show', as: :question_bank

    get 'courses/:subject_area_name_url/:institution_name_url/:qualification_name_url/:exam_level_name_url/:exam_section_name_url/:course_module_name_url(/:course_module_element_name_url)', to: 'courses#show', as: :course

    get 'library/:exam_level_name_url/question_banks/new', to: 'question_banks#new', as: :level_question_banks
    get 'library/:exam_level_name_url/:exam_section_name_url/question_banks/new', to: 'question_banks#new', as: :section_question_banks

    post 'library/:exam_level_name_url/question_banks/new', to: 'question_banks#create', as: :new_level_question_bank

    post 'library/:exam_level_name_url/:exam_section_name_url/question_banks/new', to: 'question_banks#create', as: :new_section_question_bank

    get 'courses/:subject_area_name_url',
        to: redirect('/%{locale}/library/%{subject_area_name_url}')
    get 'courses/:subject_area_name_url/:institution_name_url',
        to: redirect('/%{locale}/library/%{subject_area_name_url}/%{institution_name_url}')
    get 'courses/:subject_area_name_url/:institution_name_url/:qualification_name_url',
        to: redirect('/%{locale}/library/%{subject_area_name_url}/%{institution_name_url}/%{qualification_name_url}')
    get 'courses/:subject_area_name_url/:institution_name_url/:qualification_name_url/:exam_level_name_url',
        to: redirect('/%{locale}/library/%{subject_area_name_url}/%{institution_name_url}/%{qualification_name_url}/%{exam_level_name_url}')
    get 'courses/:subject_area_name_url/:institution_name_url/:qualification_name_url/:exam_level_name_url/:exam_section_name_url',
        to: redirect('%{locale}/library/%{subject_area_name_url}/%{institution_name_url}/%{qualification_name_url}/%{exam_level_name_url}/%{exam_section_name_url}')

    # general resources
    resources :corporate_customers
    resources :corporate_groups, except: [:show] do
      get 'edit_members', action: :edit_members
      patch 'update_members', action: :update_members
      put 'update_members', action: :update_members
    end

    resources :corporate_students
    resources :countries, concerns: :supports_reordering
    resources :courses, only: [:create] do
      match :video_watched_data, on: :collection, via: [:put, :patch]
    end
    resources :course_modules, concerns: :supports_reordering
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
    resources :course_module_elements, except: [:index], concerns: :supports_reordering
    resources :course_module_jumbo_quizzes, only: [:new, :edit, :create, :update]
    resources :currencies, concerns: :supports_reordering
    get 'dashboard', to: 'dashboard#index', as: :dashboard
    resources :exam_levels, concerns: :supports_reordering do
      get  '/filter/:qualification_url', on: :collection, action: :index, as: :filtered
    end
    resources :exam_sections, concerns: :supports_reordering do
      get  '/filter/:exam_level_url', on: :collection, action: :index, as: :filtered
    end
    get 'acca', to: 'home_pages#show', first_element: 'acca'
    get 'cfa', to: 'home_pages#show', first_element: 'cfa'
    get 'wso', to: 'home_pages#show', first_element: 'wso'
    resources :home_pages, except: [:destroy]
    post 'student_sign_up', to: 'home_pages#student_sign_up', as: :student_sign_up
    resources :institutions, concerns: :supports_reordering do
      get  '/filter/:subject_area_url', on: :collection, action: :index, as: :filtered
    end
    resources :invoices, only: [:index, :show]

    post '/subscribe', to: 'library#subscribe'

    get 'library/:exam_level_name_url(/:exam_section_name_url)', to: 'library#show', as: :library_course
    get 'library', to: 'library#index', as: :library

    #get 'library/:exam_level_name_url', to: 'library#show'
    resources :qualifications, concerns: :supports_reordering do
      get  '/filter/:institution_url', on: :collection, action: :index, as: :filtered
    end
    resources :question_banks, only: [:new, :create, :destroy]
    resources :quiz_questions, except: [:index]
    resources :static_pages
    resources :static_page_uploads, only: [:create]
    resources :stripe_developer_calls
    get 'acca-schedule', to: 'study_schedules#acca_schedule'
    resources :subject_areas, concerns: :supports_reordering
    resources :subscriptions, only: [:create, :update, :destroy]
    resources :subscription_payment_cards, only: [:create, :update]
    resources :subscription_plans
    resources :subscription_plan_categories
    resources :tutor_applications
    get 'tutor_profile/index'
    get 'tutor_profile/chris_ahlstrand'
    get 'tutor_profile/dave_o_donoghue'
    get 'tutor_profile/liam_doran'
    get 'tutor_profile/john_owens'
    get 'tutor_profile/sana_khan'
    get 'about', to: 'footer_pages#about_us'
    get 'jobs', to: 'footer_pages#jobs'
    get 'terms_and_conditions', to: 'footer_pages#terms_and_conditions'
    resources :user_activity_logs
    resources :user_notifications
    resources :vat_codes
    resources :marketing_categories
    resources :marketing_tokens do
      post :preview_csv, on: :collection, action: :preview_csv
      post :import_csv, on: :collection, action: :import_csv
      get :download_csv, on: :collection, action: :download_csv
    end
    resources :referral_codes, except: [:new, :edit, :update]
    resources :referred_signups, only: [:index, :edit, :update] do
      get  '/filter/:payed', on: :collection, action: :index, as: :filtered
    end

    # home page
    root 'home_pages#show'

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
