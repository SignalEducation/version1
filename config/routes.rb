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
    post 'stripe_v02', to: 'stripe_v02#create'
  end

  # all standard, user-facing "resources" go inside this scope
  scope '(:locale)', locale: /en/ do # /en\nl\pl/
    get '404' => redirect('404-page')
    get '500' => redirect('500-page')

    # users and authentication
    resources :users do
      resources :visits, only: [:index, :show]
    end

    get 'new_subscription', to: 'subscriptions#new', as: :new_subscription
    post 'create_subscription/:user_id', to: 'subscriptions#create', as: :create_subscription

    get 'new_subscription_africa', to: 'subscription_sign_ups#new', as: :new_subscription_sign_up
    post 'create_subscription_sign_up', to: 'subscription_sign_ups#create', as: :create_subscription_sign_up
    get 'new_subscription_sign_up_complete', to: 'subscription_sign_ups#show', as: :new_subscription_sign_up_complete

    #User Account Verification
    get 'user_verification/:email_verification_code', to: 'user_verifications#update',
        as: :user_verification
    get 'account_verified', to: 'user_verifications#account_verified',
        as: :account_verified
    post 'resend_verification_mail/:email_verification_code', to: 'user_verifications#resend_verification_mail', as: :resend_verification_mail

    # User Sessions
    get 'sign_in', to: 'user_sessions#new', as: :sign_in
    resources :user_sessions, only: [:create]
    get 'sign_out', to: 'user_sessions#destroy', as: :sign_out

    # User Accounts
    get 'account', to: 'user_accounts#account_show', as: :account
    post 'change_password', to: 'user_accounts#change_password', as: :change_password
    patch 'update_user_details', to: 'user_accounts#update_user', as: :update_personal_details
    patch 'update_exam_body_user_details', to: 'user_accounts#update_exam_body_user_details', as: :update_exam_body_user_details
    get 'subscription_invoice/:id', to: 'user_accounts#subscription_invoice', as: :subscription_invoices
    get 'account/change_plan', to: 'subscriptions#change_plan', as: :account_change_plan
    put 'un_cancel_subscription/:id', to: 'subscriptions#un_cancel_subscription', as: :un_cancel_subscription

    resources :user_groups
    resources :subscription_management do
      get '/invoice/:invoice_id', action: :invoice, as: :invoice
      get '/pdf_invoice/:invoice_id', action: :pdf_invoice, as: :pdf_invoice
      get '/invoice/:invoice_id/charge/:id', action: :charge, as: :invoice_charge
      put '/cancel', action: :cancel, as: :cancel
      put '/un_cancel', action: :un_cancel_subscription, as: :un_cancel_subscription
      put '/immediate_cancel', action: :immediate_cancel, as: :immediate_cancel
      put '/reactivate', action: :reactivate_subscription, as: :reactivate_subscription
    end
    resources :users do
      get  '/personal', action: :user_personal_details, as: :personal
      get  '/subscription', action: :user_subscription_status, as: :subscription
      get  '/courses', action: :user_courses_status, as: :courses
      get  '/enrollments', action: :user_enrollments_details, as: :enrollments
      get  '/orders', action: :user_purchases_details, as: :orders
      patch  '/update_courses', action: :update_courses, as: :update_courses
    end
    resources :user_passwords, only: [:new, :edit, :create, :update]
    get 'forgot_password', to: 'user_passwords#new', as: :forgot_password
    get 'reset_password/:id', to: 'user_passwords#edit', as: :reset_password
    get 'set_password/:id', to: 'user_passwords#set_password', as: :set_password
    put 'create_password/:id', to: 'user_passwords#create_password', as: :user_create_password
    post 'manager_resend/:id', to: 'user_passwords#manager_resend_email', as: :manager_resend

    # Internal Landing Pages - post sign-up or upgrade or purchase
    get 'personal_sign_up_complete/:account_activation_code', to: 'student_sign_ups#show', as: :personal_sign_up_complete
    get 'personal_upgrade_complete', to: 'subscriptions#personal_upgrade_complete', as: :personal_upgrade_complete

    get 'courses/:subject_course_name_url/:course_module_name_url(/:course_module_element_name_url)', to: 'courses#show', as: :course
    get 'courses/:subject_course_name_url',
        to: redirect('/%{locale}/library/%{subject_course_name_url}')

    resources :countries, concerns: :supports_reordering
    resources :coupons
    post '/coupon_validation', to: 'coupons#validate_coupon', as: :coupon_validation
    resources :courses, only: [:create] do
      match :create_video_user_log, on: :collection, via: [:post]
      match :video_watched_data, on: :collection, via: [:put, :patch]
    end
    resources :enrollments, only: [:edit, :update, :create]
    resources :enrollment_management, only: [:edit, :update, :show]
    post '/create_new_scul/:id', to: 'enrollment_management#create_new_scul', as: :reset_enrollment_scul
    get 'course_modules/:subject_course_name_url',
        to: 'course_modules#new',
        as: :new_course_modules_for_subject_course_and_name
    get 'course_modules/:subject_course_name_url', to: 'course_modules#show',
        as: :course_modules_for_subject_course
    resources :course_modules, concerns: :supports_reordering
    resources :course_module_elements, except: [:index], concerns: :supports_reordering
    get 'course_module_elements/:id/quiz_questions_order', to: 'course_module_elements#quiz_questions_order', as: :quiz_questions_order
    resources :currencies, concerns: :supports_reordering

    get '/dashboard', to: 'dashboard#show', as: :student_dashboard

    resources :exam_bodies
    resources :exam_sittings
    resources :external_banners, concerns: :supports_reordering
    resources :faqs, except: [:show, :index], concerns: :supports_reordering
    resources :faq_sections, concerns: :supports_reordering
    resources :groups, concerns: :supports_reordering

    #Sign Up Actions
    get '/student_new', to: 'student_sign_ups#new', as: :new_student
    post '/student_create', to: 'student_sign_ups#create', as: :create_student

    resources :invoices, only: [:index, :show]

    post '/subscribe', to: 'library#subscribe'
    post '/home_page_subscribe', to: 'student_sign_ups#subscribe'
    post '/info_subscribe', to: 'footer_pages#info_subscribe'
    post '/complaints_intercom', to: 'footer_pages#complaints_intercom'
    post '/contact_us_intercom', to: 'footer_pages#contact_us_intercom'
    post '/tutor_contact_form', to: 'library#tutor_contact_form'

    # Library Structure

    get 'library', to: 'library#index', as: :library
    get 'library/:group_name_url', to: 'library#group_show', as: :library_group
    get 'library/:group_name_url/:subject_course_name_url', to: 'library#course_show', as: :library_course
    get 'library/:group_name_url/preview/:subject_course_name_url', to: 'library#course_preview', as: :library_preview

    resources :management_consoles
    get '/system_requirements', to: 'management_consoles#system_requirements', as: :system_requirements
    get '/public_resources', to: 'management_consoles#public_resources', as: :public_resources
    resources :mock_exams, concerns: :supports_reordering
    resources :orders, except: [:new]
    get 'order/new/:product_id', to: 'orders#new', as: :new_order
    get 'order/order_complete/:reference_guid', to: 'orders#order_complete', as: :order_complete
    resources :products
    resources :quiz_questions, except: [:index], concerns: :supports_reordering

    get '/reports', to: 'reports#index', as: :reports
    get '/export_users', to: 'reports#export_users', as: :export_users
    get '/export_users_monthly', to: 'reports#export_users_monthly', as: :export_users_monthly
    get '/export_users_with_enrollments', to: 'reports#export_users_with_enrollments', as: :export_users_with_enrollments
    get '/export_visits', to: 'reports#export_visits', as: :export_visits
    get '/export_courses', to: 'reports#export_courses', as: :export_courses
    get '/export_enrollments', to: 'reports#export_enrollments', as: :export_enrollments


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
    get '/all_subscriptions', to: 'subscription_plans#all_subscriptions', as: :all_subscriptions
    get '/subscription_show/:id', to: 'subscription_plans#subscription_show', as: :subscription_show

    resources :subject_course_resources
    get 'pricing', to: 'subscription_plans#public_index', as: :pricing
    get 'acca_info', to: 'footer_pages#acca_info'
    get 'contact', to: 'footer_pages#contact'
    get 'privacy_policy', to: 'footer_pages#privacy_policy'
    get 'terms_and_conditions', to: 'footer_pages#terms_and_conditions'
    get 'profile/:id', to: 'footer_pages#profile', as: :profile
    get 'profiles', to: 'footer_pages#profile_index', as: :tutors
    get 'welcome_video', to: 'footer_pages#welcome_video', as: :welcome_video

    resources :user_notifications
    resources :users, only: [:new, :create]

    post :preview_csv_upload, to: 'users#preview_csv_upload'
    post :import_csv_upload, to: 'users#import_csv_upload'

    resources :vat_codes
    get '/visits/all_index', to: 'visits#all_index', as: :visits_all_index
    get '/visits/all_show/:id', to: 'visits#all_show', as: :visits_all_show
    resources :referral_codes, except: [:new, :edit, :update]
    resources :referred_signups, only: [:index, :edit, :update] do
      get  '/filter/:payed', on: :collection, action: :index, as: :filtered
    end
    resources :refunds

    resources :white_papers, concerns: :supports_reordering
    get 'media_library', to: 'footer_pages#media_library', as: :media_library
    get 'white_paper/:white_paper_name_url', to: 'footer_pages#white_paper_request', as: :public_white_paper
    resources :white_paper_requests
    post 'request_white_paper', to: 'white_papers#create_request', as: :request_white_paper

    resources :home_pages

    # HomePages Structure
    get 'home', to: 'routes#root', as: :home
    get 'group/:public_url', to: 'student_sign_ups#landing', as: :group_landing

    root 'student_sign_ups#home'
    # Catch-all
    get '404', to: 'footer_pages#missing_page', first_element: '404-page'
    get '404-page', to: 'footer_pages#missing_page', first_element: '404-page'
    #Catch Old URL
    get '/:public_url', to: 'student_sign_ups#landing'

    get '(:first_element(/:second_element))', to: 'footer_pages#missing_page'
  end

  # Catch-all
  get '(:first_element(/:second_element))', to: 'footer_pages#missing_page'

end
