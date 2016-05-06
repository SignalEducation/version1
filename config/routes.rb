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
      get 'new_paid_subscription', to: 'users#new_paid_subscription', as: :new_paid_subscription
      patch 'upgrade_from_free_trial', to: 'users#upgrade_from_free_trial', as: :upgrade_from_free_trial
      get 'reactivate_account', to: 'users#reactivate_account', as: :reactivate_account
      post 'reactivate_account_subscription', to: 'users#reactivate_account_subscription', as: :reactivate_account_subscription
    end

    get 'user_verification/:email_verification_code', to: 'user_verifications#update',
        as: :user_verification
    get 'user_activate/:activation_code', to: 'user_verifications#old_mail_activation',
        as: :old_user_activation
    resources :user_groups
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

    # special routes
    get 'personal_sign_up_complete', to: 'student_sign_ups#show', as: :personal_sign_up_complete
    get 'send_verification', to: 'student_sign_ups#resend_verification_mail', as: :resend_verification_mail
    get 'personal_upgrade_complete', to: 'users#personal_upgrade_complete', as: :personal_upgrade_complete
    get 'reactivation_complete', to: 'users#reactivation_complete', as: :reactivation_complete
    get 'courses/:subject_course_name_url/question_bank/:id', to: 'courses#show', as: :course_question_bank
    get 'courses/:subject_course_name_url/:course_module_name_url(/:course_module_element_name_url)', to: 'courses#show', as: :course
    #get 'library/:subject_course_name_url/question_banks/new', to: 'question_banks#new', as: :question_banks
    #post 'library/:subject_course_name_url/question_banks/new', to: 'question_banks#create', as: :new_question_bank
    get 'courses/:subject_course_name_url',
        to: redirect('/%{locale}/library/%{subject_course_name_url}')

    # general resources
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
    post '/corporate_verification', to: 'corporate_profiles#corporate_verification'
    post '/corporate_profiles/create', to: 'corporate_profiles#create', as: :new_corporate_user
    resources :corporate_profiles, only: [:new, :show]
    resources :corporate_requests
    get 'submission_complete', to: 'corporate_requests#submission_complete', as: :submission_complete
    resources :countries, concerns: :supports_reordering
    resources :courses, only: [:create] do
      match :video_watched_data, on: :collection, via: [:put, :patch]
    end
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
    get 'dashboard', to: 'dashboard#index', as: :dashboard
    resources :groups, concerns: :supports_reordering
    resources :groups do
      get 'edit_courses', action: :edit_courses
      get 'admin_show', action: :admin_show
      patch 'update_courses', action: :update_courses
      put 'update_courses', action: :update_courses
    end

    get 'acca', to: 'home_pages#show', first_element: 'acca', as: :acca
    get 'cfa', to: 'home_pages#show', first_element: 'cfa', as: :cfa
    get 'wso', to: 'home_pages#show', first_element: 'wso', as: :wso
    get 'business', to: 'home_pages#show', first_element: 'business', as: :business
    get 'pricing', to: 'subscription_plans#public_index', as: :pricing
    resources :home_pages, except: [:destroy]
    post 'student_sign_up', to: 'home_pages#student_sign_up', as: :student_sign_up
    get '/student_new', to: 'users#student_new', as: :new_student
    post '/student_create', to: 'users#student_create', as: :create_student

    resources :invoices, only: [:index, :show]
    get 'subscription_invoice/:id', to: 'users#subscription_invoice', as: :subscription_invoices

    post '/subscribe', to: 'library#subscribe'
    post '/info_subscribe', to: 'footer_pages#info_subscribe'
    get 'library', to: 'library#index', as: :library
    get 'group/:group_name_url', to: 'groups#show', as: :library_group
    get 'course/:subject_course_name_url', to: 'library#show', as: :library_course

    resources :question_banks, only: [:new, :create, :edit, :update, :destroy]
    resources :quiz_questions, except: [:index]
    resources :static_pages
    resources :static_page_uploads, only: [:create]
    get 'acca-schedule', to: 'study_schedules#acca_schedule'
    resources :subject_courses, concerns: :supports_reordering
    get 'subject_courses/:id/course_modules_order', to: 'subject_courses#course_modules_order', as: :course_modules_order
    resources :subscriptions, only: [:create, :update, :destroy]
    resources :subscription_payment_cards, only: [:create, :update]
    resources :subscription_plans
    resources :subscription_plan_categories
    resources :tutor_applications
    get 'why-learn-signal', to: 'footer_pages#why_learn_signal', as: :why_learn_signal
    get 'careers', to: 'footer_pages#careers'
    get 'contact', to: 'footer_pages#contact'
    get 'terms_and_conditions', to: 'footer_pages#terms_and_conditions'
    get 'privacy_policy', to: 'footer_pages#privacy_policy'
    resources :user_activity_logs
    resources :user_notifications
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

    constraints(Subdomain) do
      get '/' => 'corporate_profiles#show'
    end

    # home page
    root 'home_pages#show'

    # Catch-all
    get '404', to: 'footer_pages#missing_page', first_element: '404-page'
    get '(:first_element(/:second_element))', to: 'footer_pages#missing_page'
  end

  # Catch-all
  get '(:first_element(/:second_element))', to: 'footer_pages#missing_page'

end
