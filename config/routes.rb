Rails.application.routes.draw do

  concern :supports_reordering do
    post :reorder, on: :collection
  end

  # Enable /sidekiq for admin users only
  require 'admin_constraint'
  require 'subdomain'
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new

  get '404' => redirect('404-page')
  get '500' => redirect('500-page')

  namespace :api do
    post 'stripe_v01', to: 'stripe_v01#create'
    resources :user_activities, only: :create
  end

  # all standard, user-facing "resources" go inside this scope
  scope '(:locale)', locale: /en/ do # /en\nl\pl/
    get '404' => redirect('404-page')
    get '500' => redirect('500-page')

    # users and authentication
    resources :users do
      get 'new_subscription', to: 'users#new_subscription', as: :new_subscription
      patch 'create_subscription', to: 'users#create_subscription', as: :create_subscription

      get 'reactivate_account', to: 'users#reactivate_account', as: :reactivate_account
      post 'reactivate_account_subscription', to: 'users#reactivate_account_subscription', as: :reactivate_account_subscription
    end

    #User Account & Session
    get 'user_verification/:email_verification_code', to: 'user_verifications#update',
        as: :user_verification
    get 'user_activate/:activation_code', to: 'user_verifications#old_mail_activation',
        as: :old_user_activation
    resources :user_groups
    resources :student_user_types
    get 'sign_in', to: 'user_sessions#new', as: :sign_in
    resources :user_sessions, only: [:create]
    get 'sign_out', to: 'user_sessions#destroy', as: :sign_out
    get 'account', to: 'users#show', as: :account
    get 'account/change_plan', to: 'users#change_plan', as: :account_change_plan
    get 'profile/:id', to: 'users#profile', as: :profile
    get 'profiles', to: 'users#profile_index', as: :tutors
    post 'change_password', to: 'users#change_password', as: :change_password
    resources :user_password_resets, only: [:new, :edit, :create, :update]
    get 'forgot_password', to: 'user_password_resets#new', as: :forgot_password
    get 'reset_password/:id', to: 'user_password_resets#edit', as: :reset_password
    get 'set_password/:id', to: 'user_password_resets#corporate_new', as: :set_password
    put 'create_password/:id', to: 'user_password_resets#corporate_create', as: :user_create_password
    get 'send_verification', to: 'student_sign_ups#resend_verification_mail', as: :resend_verification_mail

    # Internal Landing Pages - post sign-up or upgrade or purchase
    get 'personal_sign_up_complete', to: 'student_sign_ups#show', as: :personal_sign_up_complete
    get 'personal_upgrade_complete', to: 'users#personal_upgrade_complete', as: :personal_upgrade_complete
    get 'reactivation_complete', to: 'users#reactivation_complete', as: :reactivation_complete

    get 'courses/:subject_course_name_url/question_bank/:id', to: 'courses#show', as: :course_question_bank
    get 'courses/:subject_course_name_url/:course_module_name_url(/:course_module_element_name_url)', to: 'courses#show', as: :course
    get 'courses/:subject_course_name_url',
        to: redirect('/%{locale}/library/%{subject_course_name_url}')

    # Corporate Routes
    resources :corporate_customers
    resources :corporate_groups do
      get 'edit_members', action: :edit_members
      patch 'update_members', action: :update_members
      put 'update_members', action: :update_members
    end
    resources :corporate_managers
    resources :corporate_students
    resources :corporate_students do
      post :import_csv, on: :collection, action: :import_corporate_students
      post :preview_csv, on: :collection, action: :preview_corporate_students
    end
    get '/login', to: 'corporate_profiles#login', as: :corporate_login
    get '/corp_home', to: 'corporate_profiles#show', as: :corporate_home
    post '/corporate_verification', to: 'corporate_profiles#corporate_verification'
    post '/corporate_profiles/create', to: 'corporate_profiles#create', as: :new_corporate_user
    resources :corporate_profiles, only: [:new, :show]
    resources :corporate_requests
    get 'submission_complete', to: 'corporate_requests#submission_complete', as: :submission_complete

    # General Resources
    resources :countries, concerns: :supports_reordering
    resources :courses, only: [:create] do
      match :video_watched_data, on: :collection, via: [:put, :patch]
    end
    get '/enrollments/:subject_course_name_url', to: 'enrollments#create', as: :new_enrollment
    get '/orders/enrollment/:subject_course_name_url', to: 'enrollments#create_with_order', as: :new_order_enrollment

    post '/enrollments/:subject_course_name_url', to: 'users#enrollment', as: :user_enrollment

    get 'enrollments/:enrollment_id/pause', to: 'enrollments#pause', as: :pause_enrollment
    get 'enrollments/:enrollment_id/activate', to: 'enrollments#activate', as: :activate_enrollment
    get 'course_modules/:subject_course_name_url',
        to: 'course_modules#new',
        as: :new_course_modules_for_subject_course_and_name
    get 'course_modules/:subject_course_name_url', to: 'course_modules#show',
        as: :course_modules_for_subject_course
    resources :course_modules, concerns: :supports_reordering
    resources :course_module_elements, except: [:index], concerns: :supports_reordering
    resources :course_module_jumbo_quizzes, only: [:new, :edit, :create, :update]
    get 'completion_cert/:id', to: 'library#cert', as: :completion_certs
    resources :currencies, concerns: :supports_reordering

    get '/dashboard/student', to: 'dashboard#student', as: :student_dashboard
    get '/dashboard/admin', to: 'dashboard#admin', as: :admin_dashboard
    get '/dashboard/tutor', to: 'dashboard#tutor', as: :tutor_dashboard
    get '/dashboard/content_manager', to: 'dashboard#content_manager', as: :content_manager_dashboard
    get '/dashboard/corporate_manager', to: 'dashboard#corporate_customer', as: :corporate_customer_dashboard
    get '/dashboard/corporate_student', to: 'dashboard#corporate_student', as: :corporate_student_dashboard

    resources :exam_sittings
    resources :groups, concerns: :supports_reordering
    resources :groups do
      get 'edit_courses', action: :edit_courses
      get 'admin_show', action: :admin_show
      patch 'update_courses', action: :update_courses
      put 'update_courses', action: :update_courses
    end

    post 'student_sign_up', to: 'home_pages#student_sign_up', as: :student_sign_up
    get '/student_new', to: 'users#student_new', as: :new_student
    post '/student_create', to: 'users#student_create', as: :create_student

    resources :invoices, only: [:index, :show]
    get 'subscription_invoice/:id', to: 'users#subscription_invoice', as: :subscription_invoices

    post '/subscribe', to: 'library#subscribe'
    post '/home_page_subscribe', to: 'home_pages#subscribe'
    post '/info_subscribe', to: 'footer_pages#info_subscribe'




    # Library Structure
    get 'subscription_groups', to: 'library#group_index', as: :subscription_groups
    get 'subscription_group/:group_name_url', to: 'library#group_show', as: :subscription_group
    get 'subscription_course/:subject_course_name_url', to: 'library#course_show', as: :subscription_course
    get 'product_course/:subject_course_name_url', to: 'library#diploma_show', as: :diploma_course



     get 'new_product_user/:subject_course_name_url', to: 'users#new_product_user', as: :new_product_user
    get 'new_session_product/:subject_course_name_url', to: 'users#new_session_product', as: :new_session_product
    get 'users_new_order/:subject_course_name_url', to: 'orders#new', as: :users_new_order
    post '/create_product_user', to: 'users#create_product_user', as: :create_product_user

    post '/create_session_product', to: 'users#create_session_product', as: :create_session_product

    resources :orders
    resources :products
    resources :question_banks, only: [:new, :create, :edit, :update, :destroy]
    resources :quiz_questions, except: [:index]
    resources :static_pages
    resources :static_page_uploads, only: [:create]
    resources :subject_courses, concerns: :supports_reordering
    get 'subject_courses/:id/course_modules_order', to: 'subject_courses#course_modules_order', as: :course_modules_order

    resources :subscriptions, only: [:create, :update, :destroy]
    resources :subscription_payment_cards, only: [:create, :update]
    resources :subscription_plans
    resources :subscription_plan_categories
    resources :subject_course_categories
    resources :tutor_applications
    get 'pricing', to: 'subscription_plans#public_index', as: :pricing
    get 'business', to: 'footer_pages#business', as: :business
    get 'careers', to: 'footer_pages#careers'
    get 'contact', to: 'footer_pages#contact'
    get 'privacy_policy', to: 'footer_pages#privacy_policy'
    get 'terms_and_conditions', to: 'footer_pages#terms_and_conditions'
    get 'why-learn-signal', to: 'footer_pages#why_learn_signal', as: :why_learn_signal
    resources :user_activity_logs
    resources :user_notifications
    resources :user_exam_sittings
    resources :users, only: [:new, :create]
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

    resources :white_papers, except: [:show, :media_library], concerns: :supports_reordering
    get 'media_library', to: 'white_papers#media_library', as: :media_library
    get 'white_paper/:white_paper_name_url', to: 'white_papers#show', as: :public_white_paper
    resources :white_paper_requests
    post 'request_white_paper', to: 'white_papers#create_request', as: :request_white_paper

    resources :home_pages, only: [:index, :new, :edit, :update, :create]

    # HomePage Structure
    #HomePage or Root
    get 'home', to: 'home_pages#home', as: :home
    #Product Course Landing Pages
    get 'diploma/:home_pages_public_url', to: 'home_pages#diploma', as: :product_course
    #Subscription Group/Course Landing Pages
    get 'group/:home_pages_public_url', to: 'home_pages#group', as: :group_landing

    get 'all_groups', to: 'home_pages#group_index', as: :all_groups
    get 'all_diploma', to: 'home_pages#diploma_index', as: :all_diplomas


    constraints(Subdomain) do
      get '/' => 'routes#root'
    end

    # home page
    root 'routes#root'


    # Catch-all
    get '404', to: 'footer_pages#missing_page', first_element: '404-page'
    get '404-page', to: 'footer_pages#missing_page', first_element: '404-page'
    #Catch Old URL
    get '/:home_pages_public_url', to: 'home_pages#group'

    get '(:first_element(/:second_element))', to: 'footer_pages#missing_page'
  end

  # Catch-all
  get '(:first_element(/:second_element))', to: 'footer_pages#missing_page'

end
