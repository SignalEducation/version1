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
    post 'stripe_v01', to: 'stripe_v01#create'
  end

  # all standard, user-facing "resources" go inside this scope
  scope '(:locale)', locale: /en/ do # /en\nl\pl/
    get '404' => redirect('404-page')
    get '500' => redirect('500-page')

    # users and authentication
    resources :users do
      get 'new_subscription', to: 'subscriptions#new_subscription', as: :new_subscription
      patch 'create_subscription', to: 'subscriptions#create_subscription', as: :create_subscription

      get 'reactivate_account', to: 'users#reactivate_account', as: :reactivate_account
      post 'reactivate_account_subscription', to: 'users#reactivate_account_subscription', as: :reactivate_account_subscription
      resources :visits, only: [:index, :show]
    end

    #User Account & Session
    get 'user_verification/:email_verification_code', to: 'user_verifications#update',
        as: :user_verification
    get 'account_verified', to: 'student_sign_ups#account_verified',
        as: :account_verified
    get 'user_activate/:activation_code', to: 'user_verifications#old_mail_activation',
        as: :old_user_activation
    resources :user_groups
    get 'sign_in', to: 'user_sessions#new', as: :sign_in
    resources :user_sessions, only: [:create]
    get 'sign_out', to: 'user_sessions#destroy', as: :sign_out
    get 'account', to: 'users#account', as: :account
    get 'account/change_plan', to: 'subscriptions#change_plan', as: :account_change_plan
    post 'change_password', to: 'users#change_password', as: :change_password
    resources :user_password_resets, only: [:new, :edit, :create, :update]
    get 'forgot_password', to: 'user_password_resets#new', as: :forgot_password
    get 'reset_password/:id', to: 'user_password_resets#edit', as: :reset_password
    get 'set_password/:id', to: 'user_password_resets#set_password', as: :set_password
    put 'create_password/:id', to: 'user_password_resets#create_password', as: :user_create_password
    get 'send_verification/:email_verification_code', to: 'student_sign_ups#resend_verification_mail', as: :resend_verification_mail
    get 'resend_verification/:email_verification_code', to: 'student_sign_ups#admin_resend_verification_mail', as: :admin_resend_verification_mail

    # Internal Landing Pages - post sign-up or upgrade or purchase
    get 'personal_sign_up_complete/:account_activation_code', to: 'student_sign_ups#show', as: :personal_sign_up_complete
    get 'personal_upgrade_complete', to: 'subscriptions#personal_upgrade_complete', as: :personal_upgrade_complete
    get 'reactivation_complete', to: 'users#reactivation_complete', as: :reactivation_complete

    get 'courses/:subject_course_name_url/:course_module_name_url(/:course_module_element_name_url)', to: 'courses#show', as: :course
    get 'courses/:subject_course_name_url',
        to: redirect('/%{locale}/library/%{subject_course_name_url}')

    resources :corporate_requests
    get 'submission_complete', to: 'corporate_requests#submission_complete', as: :submission_complete
    resources :countries, concerns: :supports_reordering
    resources :courses, only: [:create] do
      match :video_watched_data, on: :collection, via: [:put, :patch]
    end
    post '/create_discourse_user', to: 'users#create_discourse_user', as: :user_create_discourse_user
    get '/enrollments/basic_create/:subject_course_name_url', to: 'enrollments#basic_create', as: :enrollment_basic_create
    get 'enrollments/:enrollment_id/pause', to: 'enrollments#pause', as: :pause_enrollment
    get 'enrollments/:enrollment_id/activate', to: 'enrollments#activate', as: :activate_enrollment
    resources :enrollments, only: [:edit, :update, :create]
    get 'course_modules/:subject_course_name_url',
        to: 'course_modules#new',
        as: :new_course_modules_for_subject_course_and_name
    get 'course_modules/:subject_course_name_url', to: 'course_modules#show',
        as: :course_modules_for_subject_course
    resources :course_modules, concerns: :supports_reordering
    resources :course_module_elements, except: [:index], concerns: :supports_reordering
    resources :course_module_jumbo_quizzes, only: [:new, :edit, :create, :update]
    get 'course_module_elements/:id/quiz_questions_order', to: 'course_module_elements#quiz_questions_order', as: :quiz_questions_order
    get 'completion_cert/:id', to: 'library#cert', as: :completion_certs
    resources :currencies, concerns: :supports_reordering

    get '/dashboard/export_users', to: 'dashboard#export_users', as: :export_users
    get '/dashboard/export_users_monthly', to: 'dashboard#export_users_monthly', as: :export_users_monthly
    get '/dashboard/export_users_with_enrollments', to: 'dashboard#export_users_with_enrollments', as: :export_users_with_enrollments
    get '/dashboard/export_visits', to: 'dashboard#export_visits', as: :export_visits
    get '/dashboard/export_courses', to: 'dashboard#export_courses', as: :export_courses
    get '/dashboard', to: 'dashboard#student', as: :student_dashboard
    get '/dashboard/admin', to: 'dashboard#admin', as: :admin_dashboard
    get '/dashboard/tutor', to: 'dashboard#tutor', as: :tutor_dashboard
    get '/dashboard/content_manager', to: 'dashboard#content_manager', as: :content_manager_dashboard
    get '/dashboard/marketing_manager', to: 'dashboard#marketing_manager', as: :marketing_manager_dashboard
    get '/dashboard/customer_support_manager', to: 'dashboard#customer_support_manager', as: :customer_support_manager_dashboard

    resources :exam_bodies
    resources :exam_sittings
    resources :groups, concerns: :supports_reordering
    resources :groups do
      get 'edit_courses', action: :edit_courses
      get 'admin_show', action: :admin_show
      patch 'update_courses', action: :update_courses
      put 'update_courses', action: :update_courses
    end

    #Sign Up Actions
    get '/student_new', to: 'student_sign_ups#new', as: :new_student
    post '/student_create', to: 'student_sign_ups#create', as: :create_student

    resources :invoices, only: [:index, :show]
    get 'subscription_invoice/:id', to: 'users#subscription_invoice', as: :subscription_invoices

    post '/subscribe', to: 'library#subscribe'
    post '/home_page_subscribe', to: 'home_pages#subscribe'
    post '/info_subscribe', to: 'footer_pages#info_subscribe'
    post '/complaints_zendesk', to: 'footer_pages#complaints_zendesk'
    post '/contact_us_zendesk', to: 'footer_pages#contact_us_zendesk'

    # Library Structure
    # Catch old library urls
    get 'subscription_groups', to: 'library#index'
    get 'subscription_group/:group_name_url', to: 'library#group_show'
    get 'subscription_course/:subject_course_name_url', to: 'library#index'

    get 'library', to: 'library#index', as: :library
    get 'library/:group_name_url', to: 'library#group_show', as: :library_group
    get 'library/:group_name_url/:subject_course_name_url', to: 'library#course_show', as: :library_course
    get 'library/:group_name_url/:subject_course_name_url/preview', to: 'library#preview_course', as: :preview_course

    resources :mock_exams, concerns: :supports_reordering
    resources :orders, except: [:new]
    get 'order/new/:product_id', to: 'orders#new', as: :new_order
    resources :products
    resources :quiz_questions, except: [:index], concerns: :supports_reordering
    resources :subject_courses, concerns: :supports_reordering do
      get 'edit_tutors', action: :edit_tutors, as: :edit_course_tutors
      patch 'update_tutors', action: :update_tutors, as: :update_course_tutors
    end
    get 'subject_courses/:id/course_modules_order', to: 'subject_courses#course_modules_order', as: :course_modules_order
    post 'subject_courses/:id/update_user_logs', to: 'subject_courses#update_student_exam_tracks', as: :subject_course_update_user_logs
    get 'subject_courses/:id/resources', to: 'subject_courses#subject_course_resources', as: :course_resources
    get 'subject_courses/:id/new_subject_course_resources', to: 'subject_courses#new_subject_course_resources', as: :new_course_resources
    post 'subject_courses/:id/create_subject_course_resources', to: 'subject_courses#create_subject_course_resources', as: :create_course_resources

    resources :subscriptions, only: [:update, :destroy]
    resources :subscription_payment_cards, only: [:create, :update, :destroy]
    resources :subscription_plans
    resources :subscription_plan_categories
    resources :subject_course_resources
    resources :tutor_applications
    get 'pricing', to: 'subscription_plans#public_index', as: :pricing
    get 'business', to: 'footer_pages#business', as: :business
    get 'acca_info', to: 'footer_pages#acca_info'
    get 'contact', to: 'footer_pages#contact'
    get 'privacy_policy', to: 'footer_pages#privacy_policy'
    get 'terms_and_conditions', to: 'footer_pages#terms_and_conditions'
    get 'why-learn-signal', to: 'footer_pages#why_learn_signal', as: :why_learn_signal
    get 'profile/:id', to: 'footer_pages#profile', as: :profile
    get 'profiles', to: 'footer_pages#profile_index', as: :tutors

    resources :user_notifications
    resources :users, only: [:new, :create] do
      get  '/user_personal_details', action: :user_personal_details, as: :personal_details
      get  '/user_subscription_status', action: :user_subscription_status, as: :subscription_status
      get  '/user_courses_status', action: :user_courses_status, as: :courses_status
      get  '/user_enrollments_details', action: :user_enrollments_details, as: :enrollments_details
      get  '/user_purchases_details', action: :user_purchases_details, as: :purchases_details
      patch  '/update_courses', action: :update_courses, as: :update_courses
    end
    resources :vat_codes
    get '/visits/all_index', to: 'visits#all_index', as: :visits_all_index
    get '/visits/all_show/:id', to: 'visits#all_show', as: :visits_all_show
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

    # HomePages Structure
    get 'home', to: 'routes#root', as: :home
    get 'group/:home_pages_public_url', to: 'home_pages#group', as: :group_landing

    root 'home_pages#home'
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
