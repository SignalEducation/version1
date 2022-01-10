# frozen_string_literal: true

Rails.application.routes.draw do
  concern :supports_reordering do
    post :reorder, on: :collection
  end

  # Enable /sidekiq for admin users only
  require 'admin_constraint'
  mount Sidekiq::Web, at: '/sidekiq', constraints: AdminConstraint.new
  mount Blazer::Engine, at: 'blazer'
  mount Split::Dashboard, at: 'split', constraints: AdminConstraint.new

  get '404' => redirect('404-page')

  # API
  namespace :api do
    post 'stripe_webhooks', to: 'stripe_webhooks#create'
    post 'stripe_v02',      to: 'stripe_webhooks#create'
    post 'paypal_webhooks', to: 'paypal_webhooks#create'
    post 'cron_tasks/:id',  to: 'cron_tasks#create'
    post 'messages',        to: 'messages#update'

    namespace :v1, constraints: ApiConstraint.new(version: 1) do
      namespace :auth do
        post 'login'
        post 'logout'
      end

      resources :cbes, format: 'json', only: %i[index show create edit update] do
        scope module: 'cbes' do
          resources :sections, only: %i[index create update destroy], shallow: true do
            resources :questions, only: %i[index create update destroy]
            resources :scenarios, only: %i[create update destroy] do
              resources :exhibits, only: %i[create update destroy]
              resources :requirements, only: %i[create update destroy]
              resources :response_options, only: %i[create update destroy]
              resources :questions, only: %i[index create update destroy]
            end
          end

          resources :introduction_pages, only: %i[index create update destroy]
          resources :resources, only: %i[index create update destroy]
          resources :users_log, only: %i[index show create update] do
            post 'user_agreement'
            post 'current_state'
          end
          resources :scenarios, only: :show
          resources :users_answer, only: :show
          resources :users_response, only: :show
        end
      end

      resources :courses, only: :index do
        collection do
          get 'groups(/:group_name)', to: 'courses#groups'
          get 'lessons/:group_name/:course_name', to: 'courses#lessons'
        end

        post 'read_note_log'
      end

      resources :course_step_log, only: :show, format: 'json' do
        resources :practice_questions, only: %i[show update]
      end

      resources :exam_bodies, only: :index
      resources :key_areas, only: :index
      resources :practice_questions, only: :index
      resources :uploads, only: :create

      resources :users, only: %i[show create update] do
        post 'change_password'
        get 'forgot_password', on: :collection
        get 'resend_verify_user_email'
      end

      get 'pricing/', to: 'prices#index', as: :pricing
    end
  end

  # all standard, user-facing "resources" go inside this scope
  get '404' => redirect('404-page')

  scope "(:locale)", locale: /en/ do
    namespace :admin do
      resources :bearers
      resources :exercises, only: %i[index show new create edit update] do
        get 'generate_daily_summary', on: :collection
        get 'correct_cbe', to: 'exercises#correct_cbe', as: :correct_cbe, on: :member
        post 'return_cbe', to: 'exercises#return_cbe', as: :return_cbe, on: :member
        post 'cbe_user_question_update/answer/:question_id', to: 'exercises#cbe_user_question_update', as: :cbe_user_question_update, on: :member
        post 'cbe_user_response_update/:response_id', to: 'exercises#cbe_user_response_update', as: :cbe_user_response_update, on: :member
        post 'cbe_user_educator_comment/:cbe_user_log_id', to: 'exercises#cbe_user_educator_comment', as: :cbe_user_log_update, on: :member
      end
      namespace :exercises do
        resources :csvs do
          collection do
            post :preview
            post :upload
          end
        end
      end

      resources :users do
        resources :exercises, only: %i[index new create]
      end

      resources :cbes, only: %i[index new show update] do
        post :clone, to: 'cbes#clone', as: :cbe_clone, on: :member
      end

      resources :system_settings, only: %i[index update]
      resources :orders, only: %i[index show update] do
        get :update_product
      end

      post 'search_exercises', to: 'exercises#index', as: :search_exercises

      resources :levels, concerns: :supports_reordering do
        post :by_group, on: :collection
      end
      resources :key_areas, concerns: :supports_reordering

      get 'courses/:id/new_course_section',                                                     to: 'course_sections#new',               as: :new_course_section
      get 'courses/:id/course_section/:course_section_id/new_course_lesson',                    to: 'course_lessons#new',                as: :new_course_lesson
      get 'courses/:id/new_free_course_lesson',                                                 to: 'course_lessons#new',                as: :new_free_course_lesson
      get 'courses/:id/course_section/:course_section_id/edit_course_lesson/:course_lesson_id', to: 'course_lessons#edit',               as: :edit_course_lesson
      get 'courses/:id/course_section/:course_section_id/course_lesson/:course_lesson_id',      to: 'course_lessons#show',               as: :show_course_lesson
      get 'courses/:course_id/reorder_course_sections',                                         to: 'course_sections#reorder_list',      as: :reorder_course_sections
      get 'courses/:id/course_lessons_order',                                                   to: 'courses#course_lessons_order',      as: :course_lessons_order
      get 'courses/:id/free_lesson',                                                            to: 'courses#free_lesson',               as: :course_free_lesson_content
      get 'courses/:id/resources',                                                              to: 'courses#course_resources',          as: :course_resources
      get 'courses/:id/new_course_resources',                                                   to: 'courses#new_course_resources',      as: :new_course_resources
      post 'courses/:id/resources/reorder',                                                     to: 'course_resources#reorder',          as: :course_resources_reorder
      post 'courses/:id/update_user_logs',                                                      to: 'courses#update_course_lesson_logs', as: :course_update_user_logs
      post 'courses/:id/create_course_resources',                                               to: 'courses#create_course_resources',   as: :create_course_resources
      post 'courses/:id/clone',                                                                 to: 'courses#clone',                     as: :course_clone
      post 'courses/check_accredible_group',                                                    to: 'courses#check_accredible_group',    as: :check_accredible_group
      patch 'courses/:id/trial_content',                                                        to: 'courses#update_trial_content',      as: :course_update_trial_content

      resources :courses, concerns: :supports_reordering do
        resources :course_tutors, concerns: :supports_reordering
      end

      resources :course_resources
      resources :course_sections, concerns: :supports_reordering
      resources :course_lessons, concerns: :supports_reordering
      resources :course_steps, except: [:index], concerns: :supports_reordering do
        resources :course_notes, except: [:show], concerns: :supports_reordering
        post :clone, to: 'course_steps#clone'
      end

      delete 'course_steps/:id/remove_question/:question_id', to: 'course_steps#remove_question', as: :practice_question_remove_question
      get 'course_steps/:id/quiz_questions_order', to: 'course_steps#quiz_questions_order', as: :quiz_questions_order

      resources :course_steps do
        resources :practice_questions do
          resources :exhibits do
            patch 'update', to: 'exhibits#update'
          end
          resources :solutions do
            patch 'update', to: 'solutions#update'
          end
        end
      end

      # Categories
      resources :categories, except: :destroy

      # Sub Categories
      resources :sub_categories, except: :destroy
    end

    # Subscriptions
    resources :subscriptions, only: %i[show new create update destroy] do
      member do
        put 'un_cancel'
        get 'execute'
        get 'unapproved'
        post 'status_from_stripe'
        post 'expire_incomplete'
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
      get '/order/:order_id',                action: :order,                   as: :order
      get '/pdf_invoice/:invoice_id',        action: :pdf_invoice,             as: :pdf_invoice
      get '/invoice/:invoice_id/charge/:id', action: :charge,                  as: :invoice_charge
      get '/cancellation',                   action: :cancellation,            as: :admin_cancellations
      post '/cancel',                        action: :cancel_subscription,     as: :cancel_subscription
      put '/un_cancel',                      action: :un_cancel_subscription,  as: :un_cancel_subscription
      put '/reactivate',                     action: :reactivate_subscription, as: :reactivate_subscription
    end

    resources :order_management do
      get '/order/:id',                      action: :order,                               as: :order
      post '/cancel',                        action: :cancel_order,                        as: :cancel_order
      put '/un_cancel',                      action: :un_cancel_order,                     as: :un_cancel_order
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
      get  '/course_log_details/:scul_id',              action: :course_log_details, as: :scul_activity
      get  '/orders',                                   action: :user_purchases_details,          as: :orders
      get  '/referrals',                                action: :user_referral_details,           as: :referrals
      get  '/messages',                                 action: :user_messages_details,           as: :messages
      post '/update_hubspot',                           action: :update_hubspot,                  as: :update_hubspot
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
    post 'resend_verification_mail/:email_verification_code', to: 'user_verifications#resend_verification_mail', as: :resend_verification_mail
    get 'registration_onboarding/:group_url',                 to: 'user_verifications#account_verified',         as: :registration_onboarding
    get 'messages/unsubscribe/:message_guid',                 to: 'messages#unsubscribe',                        as: :unsubscribe

    resources :user_groups
    resources :content_pages, except: [:show]
    resources :content_activations, only: %i[new create]
    resource :preferred_exam_body, only: %i[edit update]

    resources :invoices, only: %i[show update] do
      get :pdf, on: :member, defaults: { format: 'pdf' }
    end

    # Internal Landing Pages - post sign-up or upgrade or purchase
    get 'personal_sign_up_complete', to: 'student_sign_ups#show', as: :personal_sign_up_complete
    get 'personal_upgrade_complete(/:completion_guid)', to: 'subscriptions#personal_upgrade_complete', as: :personal_upgrade_complete

    # Courses
    resources :courses, only: :update do
      match :create_video_user_log,                on: :collection, via: :post
      match :video_watched_data,                   on: :collection, via: %i[put patch]
      match :create_constructed_response_user_log, on: :collection, via: :post
      match :update_constructed_response_user_log, on: :collection, via: %i[put patch]
      post :update_quiz_attempts, on: :collection
      post :units_by_key_area, on: :collection

      get ':course_name_url', to: redirect('/library/%{course_name_url}'), on: :collection
    end

    post 'courses/search', to: 'courses#search'

    get 'courses/:course_name_url/:course_section_name_url/:course_lesson_name_url(/:course_step_name_url)', to: 'courses#show', as: 'show_course'

    get 'submit_constructed_response_user_log/:cmeul_id', to: 'courses#submit_constructed_response_user_log', as: :submit_constructed_response_user_log
    get 'courses_constructed_response/:course_name_url/:course_section_name_url/:course_lesson_name_url/:course_step_name_url(/:course_step_log_id)', to: 'courses#show_constructed_response', as: :courses_constructed_response

    get '/export_course_log_data/:id',                                                        to: 'courses#export_course_user_logs',   as: :export_course_log_data
    get 'course_lessons/:course_name_url',                                                    to: 'course_lessons#new',                as: :new_course_lessons_for_course_and_name

    resources :countries, concerns: :supports_reordering do
      get 'search', to: 'countries#index', on: :collection
    end
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
      resources :orders, except: %i[index show order_complete] do
        get 'execute', on: :member
      end
    end
    get 'orders/:exam_body_id/lifetime-membership', to: 'orders#new'
    get 'order_complete/:order_id/:product_type/:product_id', to: 'orders#order_complete', as: :order_complete
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

    post '/user_contact_form',   to: 'library#user_contact_form'

    get 'register_or_login', to: 'student_sign_ups#sign_in_or_register', as: :sign_in_or_register
    get 'sign_in_checkout', to: 'student_sign_ups#sign_in_checkout', as: :sign_in_checkout

    get 'pricing/(:group_name_url)', to: 'student_sign_ups#pricing', as: :pricing

    # Library Structure
    get 'library',                                          to: 'library#index',       as: :library
    get 'library/:group_name_url',                          to: 'library#group_show',  as: :library_group
    get 'library/:group_name_url/:course_name_url', to: 'library#course_show', as: :library_course

    resources :management_consoles
    get '/system_requirements', to: 'management_consoles#system_requirements', as: :system_requirements
    get '/external-content', to: 'management_consoles#public_resources', as: :public_resources

    # Reports
    get '/reports',                       to: 'reports#index',                            as: :reports
    get '/reports/sales',                 to: 'reports#sales',                            as: :reports_sales
    get '/reports/refunds',               to: 'reports#refunds',                          as: :reports_refunds
    get '/reports/orders',                to: 'reports#orders',                           as: :reports_orders
    get '/export_users',                  to: 'reports#export_users',                     as: :export_users
    get '/export_users_monthly',          to: 'reports#export_users_monthly',             as: :export_users_monthly
    get '/export_users_with_enrollments', to: 'reports#export_users_with_enrollments',    as: :export_users_with_enrollments
    get '/export_visits',                 to: 'reports#export_visits',                    as: :export_visits
    get '/export_courses',                to: 'reports#export_courses',                   as: :export_courses
    get '/export_enrollments',            to: 'reports#export_enrollments',               as: :export_enrollments
    post '/export_sales_report',          to: 'reports#export_sales_report',              as: :export_sales_report
    post '/export_refunds_report',        to: 'reports#export_refunds_report',            as: :export_refunds_report
    post '/export_orders_report',         to: 'reports#export_orders_report',             as: :export_orders_report
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

    get 'prep_products/:group_name_url', to: 'footer_pages#media_library', as: :exam_products

    # HomePages Structure
    get 'acca-free-lesson',        to: 'student_sign_ups#new_landing', as: :new_landing
    get 'home', to: 'routes#root', as: :home
    get 'course/:name_url', to: 'student_sign_ups#group', as: :group_landing

    root 'student_sign_ups#home'
    get 'logout', to: redirect { Rails.application.credentials[Rails.env.to_sym][:acqusition_domain][:url] }, as: :logout_redirect

    # Catch-all
    get '404', to: 'footer_pages#missing_page', first_element: '404-page', as: :missing_page
    get '404-page', to: 'footer_pages#missing_page', first_element: '404-page'
    get '/500', to: 'error#internal_error'
    get '/:public_url', to: 'student_sign_ups#landing', as: :footer_landing_page
    get 'content/:content_public_url', to: 'content_pages#show', as: :footer_content_page

    get '(:first_element(/:second_element))', to: 'footer_pages#missing_page'

  end
  # Catch-all
  get '(:first_element(/:second_element))', to: 'footer_pages#missing_page'
end
