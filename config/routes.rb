# frozen_string_literal: true

Rails.application.routes.draw do
  concern :supports_reordering do
    post :reorder, on: :collection
  end

  # Enable /sidekiq for admin users only
  require 'admin_constraint'
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new
  mount Blazer::Engine, at: 'blazer'

  get '404' => redirect('404-page')
  get '500' => redirect('500-page')

  # API
  namespace :api do
    post 'stripe_webhooks', to: 'stripe_webhooks#create'
    post 'stripe_v02',      to: 'stripe_webhooks#create'
    post 'paypal_webhooks', to: 'paypal_webhooks#create'

    namespace :v1, constraints: ApiConstraint.new(version: 1) do
      resources :subject_courses, only: :index
      resources :cbes, format: 'json', only: %i[index show create edit update] do
        scope module: 'cbes' do
          resources :sections, only: %i[index create update], shallow: true do
            resources :questions, only: %i[index create update]
            resources :scenarios, only: %i[create update] do
              resources :questions, only: %i[index create update]
            end
          end
          resources :introduction_pages, only: %i[index create update]
          resources :resources, only: %i[index create]
          resources :users_log, only: %i[index show create update]
        end
      end
    end
  end

  namespace :admin do
    resources :exercises, only: %i[index show new create edit update] do
      get 'generate_daily_summary', on: :collection
      get 'correct_cbe', to: 'exercises#correct_cbe', as: :correct_cbe, on: :member
      post 'return_cbe', to: 'exercises#return_cbe', as: :return_cbe, on: :member
      post 'cbe_user_question_update/answer/:question_id', to: 'exercises#cbe_user_question_update', as: :cbe_user_question_update, on: :member
    end
    resources :user do
      resources :exercises, only: %i[index new create]
    end

    resources :cbes,   only: %i[index new show update]
    resources :orders, only: %i[index show]
    post 'search_exercises', to: 'exercises#index', as: :search_exercises
  end

  # all standard, user-facing "resources" go inside this scope
  scope '(:locale)', locale: /en/ do # /en\nl\pl/
    get '404' => redirect('404-page')
    get '500' => redirect('500-page')

    # Subscriptions
    resources :subscriptions, only: %i[show new create update destroy] do
      member do
        put 'un_cancel'
        get 'execute'
        get 'unapproved'
        post 'status_from_stripe'
      end
      scope module: 'subscriptions' do
        resources :cancellations, only: %i[new create]
        resource :plan_changes, only: %i[show new create] do
          post :status_from_stripe, on: :member
        end
      end
    end

    resources :subscription_management do
      get '/invoice/:invoice_id',            action: :invoice,                 as: :invoice
      get '/pdf_invoice/:invoice_id',        action: :pdf_invoice,             as: :pdf_invoice
      get '/invoice/:invoice_id/charge/:id', action: :charge,                  as: :invoice_charge
      put '/cancel',                         action: :cancel,                  as: :cancel
      put '/un_cancel',                      action: :un_cancel_subscription,  as: :un_cancel_subscription
      put '/immediate_cancel',               action: :immediate_cancel,        as: :immediate_cancel
      put '/reactivate',                     action: :reactivate_subscription, as: :reactivate_subscription
    end

    resources :subscription_payment_cards, only: %i[create update destroy]
    resources :subscription_plans
    resources :subscription_plan_categories
    get '/all_subscriptions', to: 'subscription_plans#all_subscriptions', as: :all_subscriptions
    get '/subscription_show/:id', to: 'subscription_plans#subscription_show', as: :subscription_show

    # User
    resources :users do
      get  '/personal',                                 action: :user_personal_details,           as: :personal
      get  '/subscription',                             action: :user_subscription_status,        as: :subscription
      get  '/courses',                                  action: :user_courses_status,             as: :courses
      get  '/enrollments',                              action: :user_activity_details,           as: :activity
      get  '/subject_course_user_log_details/:scul_id', action: :subject_course_user_log_details, as: :scul_activity
      get  '/orders',                                   action: :user_purchases_details,          as: :orders
      get  '/referrals',                                action: :user_referral_details,           as: :referrals
      patch '/update_courses',                          action: :update_courses,                  as: :update_courses
      get 'search', on: :collection
      resources :invoices,  only: :index, shallow: true
      resources :visits,    only: %i[index show]
      resources :exercises, only: %i[index show edit update], shallow: true
    end

    # Exercises/Cbes
    get 'exercises/:exercise_id/cbes/:id', to: 'cbes#show', as: :exercise_cbes

    # Cbes
    resources :cbes, only: :show

    post '/search_visits', to: 'visits#all_index', as: :search_visits

    post :preview_csv_upload, to: 'users#preview_csv_upload'
    post :import_csv_upload, to: 'users#import_csv_upload'

    # User Sessions
    resources :user_sessions, only: :create
    get 'login',    to: 'user_sessions#new',     as: :sign_in
    get 'sign_out', to: 'user_sessions#destroy', as: :sign_out

    # User password
    resources :user_passwords, only: %i[new edit create update]
    get 'forgot_password',     to: 'user_passwords#new',                  as: :forgot_password
    get 'reset_password/:id',  to: 'user_passwords#edit',                 as: :reset_password
    get 'set_password/:id',    to: 'user_passwords#set_password',         as: :set_password
    put 'create_password/:id', to: 'user_passwords#create_password',      as: :user_create_password
    post 'manager_resend/:id', to: 'user_passwords#manager_resend_email', as: :manager_resend

    # User Accounts
    get 'account',                         to: 'user_accounts#account_show',                as: :account
    post 'change_password',                to: 'user_accounts#change_password',             as: :change_password
    patch 'update_user_details',           to: 'user_accounts#update_user',                 as: :update_personal_details
    patch 'update_exam_body_user_details', to: 'enrollments#update_exam_body_user_details', as: :update_exam_body_user_details
    get 'subscription_invoice/:id',        to: 'user_accounts#subscription_invoice',        as: :subscription_invoices
    get 'show_invoice/:guid',              to: 'user_accounts#show_invoice',                as: :show_invoice
    post 'sca_successful',                 to: 'user_accounts#sca_successful',              as: :sca_successful

    # User Account Verification
    get 'user_verification/:email_verification_code',         to: 'user_verifications#update',                   as: :user_verification
    get 'account_verified',                                   to: 'user_verifications#account_verified',         as: :account_verified
    post 'resend_verification_mail/:email_verification_code', to: 'user_verifications#resend_verification_mail', as: :resend_verification_mail
    get 'registration_onboarding/:group_url',                 to: 'user_verifications#account_verified',        as: :registration_onboarding

    resources :user_groups
    resources :content_pages, except: [:show]
    resources :content_activations, only: %i[new create]
    resource :preferred_exam_body, only: %i[edit update]

    resources :invoices, only: %i[show update] do
      get 'pdf', action: :pdf, on: :member
    end

    # Internal Landing Pages - post sign-up or upgrade or purchase
    get 'personal_sign_up_complete', to: 'student_sign_ups#show', as: :personal_sign_up_complete
    get 'personal_upgrade_complete(/:completion_guid)', to: 'subscriptions#personal_upgrade_complete', as: :personal_upgrade_complete

    # Courses
    resources :courses, only: [:create] do
      match :create_video_user_log,                on: :collection, via: :post
      match :video_watched_data,                   on: :collection, via: %i[put patch]
      match :create_constructed_response_user_log, on: :collection, via: :post
      match :update_constructed_response_user_log, on: :collection, via: %i[put patch]

      get ':subject_course_name_url', to: redirect('/%{locale}/library/%{subject_course_name_url}'), on: :collection
    end

    get 'courses/:subject_course_name_url/:course_section_name_url/:course_module_name_url(/:course_module_element_name_url)', to: 'courses#show', as: 'course'

    get 'submit_constructed_response_user_log/:cmeul_id', to: 'courses#submit_constructed_response_user_log', as: :submit_constructed_response_user_log
    get 'courses_constructed_response/:subject_course_name_url/:course_section_name_url/:course_module_name_url/:course_module_element_name_url(/:course_module_element_user_log_id)', to: 'courses#show_constructed_response', as: :courses_constructed_response

    get '/export_course_log_data/:id',                                                                to: 'subject_courses#export_course_user_logs',         as: :export_course_log_data
    get 'course_modules/:subject_course_name_url',                                                    to: 'course_modules#new',                              as: :new_course_modules_for_subject_course_and_name
    get 'subject_courses/:id/new_course_section',                                                     to: 'course_sections#new',                             as: :new_course_section
    get 'subject_courses/:id/course_section/:course_section_id/new_course_module',                    to: 'course_modules#new',                              as: :new_course_module
    get 'subject_courses/:id/course_section/:course_section_id/edit_course_module/:course_module_id', to: 'course_modules#edit',                             as: :edit_course_module
    get 'subject_courses/:id/course_section/:course_section_id/course_module/:course_module_id',      to: 'course_modules#show',                             as: :show_course_module
    get 'subject_courses/:course_id/reorder_course_sections',                                         to: 'course_sections#reorder_list',                    as: :reorder_course_sections
    get 'subject_courses/:id/course_modules_order',                                                   to: 'subject_courses#course_modules_order',            as: :course_modules_order
    post 'subject_courses/:id/update_user_logs',                                                      to: 'subject_courses#update_student_exam_tracks',      as: :subject_course_update_user_logs
    get 'subject_courses/:id/trial_content',                                                          to: 'subject_courses#trial_content',                   as: :subject_course_trial_content
    patch 'subject_courses/:id/trial_content',                                                        to: 'subject_courses#update_trial_content',            as: :subject_course_update_trial_content
    get 'subject_courses/:id/resources',                                                              to: 'subject_courses#subject_course_resources',        as: :course_resources
    get 'subject_courses/:id/new_subject_course_resources',                                           to: 'subject_courses#new_subject_course_resources',    as: :new_course_resources
    post 'subject_courses/:id/create_subject_course_resources',                                       to: 'subject_courses#create_subject_course_resources', as: :create_course_resources
    resources :subject_courses, concerns: :supports_reordering do
      resources :course_tutor_details, concerns: :supports_reordering
    end

    resources :subject_course_resources, concerns: :supports_reordering
    resources :course_sections, concerns: :supports_reordering
    resources :course_modules, concerns: :supports_reordering
    resources :course_module_elements, except: [:index], concerns: :supports_reordering do
      resources :course_module_element_resources, except: [:show], concerns: :supports_reordering
    end
    get 'course_module_elements/:id/quiz_questions_order', to: 'course_module_elements#quiz_questions_order', as: :quiz_questions_order

    resources :countries, concerns: :supports_reordering
    resources :currencies, concerns: :supports_reordering
    resources :coupons
    post 'coupon_validation', to: 'coupons#validate_coupon', as: :coupon_validation
    resources :groups, concerns: :supports_reordering
    resources :exam_bodies
    resources :exam_sittings
    resources :external_banners, concerns: :supports_reordering
    resources :faqs, except: %i[show index], concerns: :supports_reordering
    resources :faq_sections, concerns: :supports_reordering
    resources :home_pages
    resources :mock_exams, concerns: :supports_reordering, path: '/admin/mock_exams'
    resources :products, concerns: :supports_reordering, shallow: true do
      resources :orders, except: %i[index show] do
        get 'execute', on: :member
      end
    end
    resources :quiz_questions, except: [:index], concerns: :supports_reordering
    resources :refunds
    resources :vat_codes

    # Enrollments
    resources :enrollments, only: %i[edit update create]
    resources :enrollment_management, only: %i[index edit update show] do
      get 'export_log_data/:id',  action: :export_log_data, as: :export_log_data,       on: :collection
      post 'create_new_scul/:id', action: :create_new_scul, as: :reset_enrollment_scul, on: :collection
    end

    get '/dashboard', to: 'dashboard#show', as: :student_dashboard
    get '/export_exam_sitting_enrollments/:id', to: 'exam_sittings#export_exam_sitting_enrollments', as: :export_exam_sitting_enrollments

    # Sign Up Actions
    get '/basic_registration', to: 'student_sign_ups#new', as: :new_student
    get '/student_new',        to: 'student_sign_ups#new'
    post '/student_create',    to: 'student_sign_ups#create', as: :create_student

    post '/complaints_intercom', to: 'footer_pages#complaints_intercom'
    post '/contact_us_intercom', to: 'footer_pages#contact_us_intercom'

    get 'register_or_login', to: 'student_sign_ups#sign_in_or_register', as: :sign_in_or_register

    # Library Structure
    get 'library',                                          to: 'library#index',       as: :library
    get 'library/:group_name_url',                          to: 'library#group_show',  as: :library_group
    get 'library/:group_name_url/:subject_course_name_url', to: 'library#course_show', as: :library_course

    resources :management_consoles
    get '/system_requirements', to: 'management_consoles#system_requirements', as: :system_requirements
    get '/public_resources', to: 'management_consoles#public_resources', as: :public_resources

    # Reports
    get '/reports',                       to: 'reports#index',                            as: :reports
    get '/export_users',                  to: 'reports#export_users',                     as: :export_users
    get '/export_users_monthly',          to: 'reports#export_users_monthly',             as: :export_users_monthly
    get '/export_users_with_enrollments', to: 'reports#export_users_with_enrollments',    as: :export_users_with_enrollments
    get '/export_visits',                 to: 'reports#export_visits',                    as: :export_visits
    get '/export_courses',                to: 'reports#export_courses',                   as: :export_courses
    get '/export_enrollments',            to: 'reports#export_enrollments',               as: :export_enrollments
    get '/export_referral_codes',         to: 'referral_codes#export_referral_codes',     as: :export_referral_codes
    get '/export_referral_codes/:id',     to: 'referred_signups#export_referred_signups', as: :export_referred_signups
    get '/referral',                      to: 'referral_codes#referral', as: :refer_a_friend
    resources :referral_codes, except: %i[new edit update]
    resources :referred_signups, only: %i[index edit update] do
      get '/filter/:payed', on: :collection, action: :index, as: :filtered
    end

    get 'acca_info',            to: 'footer_pages#acca_info'
    get 'contact',              to: 'footer_pages#contact'
    get 'faqs',                 to: 'footer_pages#frequently_asked_questions', as: :public_faqs
    get 'privacy_policy',       to: 'footer_pages#privacy_policy'
    get 'terms_and_conditions', to: 'footer_pages#terms_and_conditions'
    get 'tutor/:name_url',      to: 'footer_pages#profile', as: :profile
    get 'tutors',               to: 'footer_pages#profile_index', as: :tutors
    get 'mock_exams',           to: 'footer_pages#media_library', as: :media_library
    get 'prep_products',        to: 'footer_pages#media_library', as: :prep_products

    # HomePages Structure
    get 'home', to: 'routes#root', as: :home
    get 'course/:name_url', to: 'student_sign_ups#group', as: :group_landing

    root 'student_sign_ups#home'

    # Catch-all
    get '404', to: 'footer_pages#missing_page', first_element: '404-page', as: :missing_page
    get '404-page', to: 'footer_pages#missing_page', first_element: '404-page'
    get '/:public_url', to: 'student_sign_ups#landing', as: :footer_landing_page
    get 'content/:content_public_url', to: 'content_pages#show', as: :footer_content_page

    get '(:first_element(/:second_element))', to: 'footer_pages#missing_page'
  end

  # Catch-all
  get '(:first_element(/:second_element))', to: 'footer_pages#missing_page'
end
