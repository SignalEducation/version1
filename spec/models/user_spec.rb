# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  email                           :string(255)
#  first_name                      :string(255)
#  last_name                       :string(255)
#  address                         :text
#  country_id                      :integer
#  crypted_password                :string(128)      default(""), not null
#  password_salt                   :string(128)      default(""), not null
#  persistence_token               :string(255)
#  perishable_token                :string(128)
#  single_access_token             :string(255)
#  login_count                     :integer          default("0")
#  failed_login_count              :integer          default("0")
#  last_request_at                 :datetime
#  current_login_at                :datetime
#  last_login_at                   :datetime
#  current_login_ip                :string(255)
#  last_login_ip                   :string(255)
#  account_activation_code         :string(255)
#  account_activated_at            :datetime
#  active                          :boolean          default("false"), not null
#  user_group_id                   :integer
#  password_reset_requested_at     :datetime
#  password_reset_token            :string(255)
#  password_reset_at               :datetime
#  stripe_customer_id              :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  locale                          :string(255)
#  guid                            :string(255)
#  subscription_plan_category_id   :integer
#  password_change_required        :boolean
#  session_key                     :string
#  name_url                        :string
#  profile_image_file_name         :string
#  profile_image_content_type      :string
#  profile_image_file_size         :integer
#  profile_image_updated_at        :datetime
#  email_verification_code         :string
#  email_verified_at               :datetime
#  email_verified                  :boolean          default("false"), not null
#  stripe_account_balance          :integer          default("0")
#  free_trial                      :boolean          default("false")
#  terms_and_conditions            :boolean          default("false")
#  date_of_birth                   :date
#  description                     :text
#  analytics_guid                  :string
#  student_number                  :string
#  unsubscribed_from_emails        :boolean          default("false")
#  communication_approval          :boolean          default("false")
#  communication_approval_datetime :datetime
#  preferred_exam_body_id          :bigint
#  currency_id                     :bigint
#  tutor_link                      :string
#  video_player                    :integer          default("0"), not null
#  subscriptions_revenue           :decimal(, )      default("0")
#  orders_revenue                  :decimal(, )      default("0")
#  home_page_id                    :integer
#  verify_remembered_at            :datetime
#  onboarding_course_id            :bigint
#
require 'rails_helper'
require Rails.root.join 'spec/concerns/user_accessable_spec.rb'

describe User do
  it_behaves_like 'user_accessable'
  it 'should have a valid factory' do
    expect(build(:user)).to be_valid
  end

  # Constants
  it { expect(User.const_defined?(:LOCALES)).to eq(true) }
  it { expect(User.const_defined?(:SORT_OPTIONS)).to eq(true) }

  # relationships
  it { should belong_to(:country) }
  it { should have_many(:course_step_logs) }
  it { should have_many(:completed_course_step_logs) }
  it { should have_many(:incomplete_course_step_logs) }
  it { should have_many(:course_tutors) }
  it { should have_many(:exam_body_user_details) }
  it { should have_many(:enrollments) }
  it { should have_many(:invoices) }
  it { should have_many(:quiz_attempts) }
  it { should have_many(:orders) }
  it { should have_many(:subscriptions) }
  it { should have_many(:subscription_payment_cards) }
  it { should have_many(:course_lesson_logs) }
  it { should have_many(:course_section_logs) }
  it { should have_many(:course_logs) }
  it { should belong_to(:user_group) }
  it { should have_many(:ahoy_visits) }
  it { should have_many(:charges) }
  it { should have_many(:refunds) }
  it { should have_many(:ahoy_events) }
  it { should have_one(:referral_code) }
  it { should have_one(:referred_signup) }
  it { should belong_to(:subscription_plan_category) }
  it { should belong_to(:currency) }
  it { should belong_to(:home_page) }
  it { should belong_to(:onboarding_course) }

  # validation
  context 'test uniqueness validation' do
    subject { FactoryBot.build(:student_user) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  it { should validate_presence_of(:email) }
  it { should validate_length_of(:email).is_at_least(5).is_at_most(50) }
  it { should validate_presence_of(:first_name) }
  it { should validate_length_of(:first_name).is_at_least(2).is_at_most(20) }
  it { should validate_presence_of(:last_name) }
  it { should validate_length_of(:last_name).is_at_least(2).is_at_most(30) }
  it { should validate_presence_of(:password).on(:create) }
  it { should validate_confirmation_of(:password).on(:create) }
  it { should validate_length_of(:password).is_at_least(6).is_at_most(255) }
  it { should_not validate_presence_of(:country_id) }
  it { should validate_presence_of(:user_group_id) }

  context 'is a student' do
    before { allow(subject).to receive(:standard_student_user?).and_return(true) }
    it { should validate_presence_of(:preferred_exam_body_id).on(:create) }
  end

  context 'is an invited student' do
    before { allow(subject).to receive(:password_change_required?).and_return(false) }
    it { should validate_presence_of(:terms_and_conditions).on(:create) }
  end

  context 'is a tutor' do
    before { allow(subject).to receive(:tutor_user?).and_return(true) }
    it { should validate_presence_of(:name_url) }
    it { should validate_presence_of(:tutor_link) }
  end

  context 'is not a tutor' do
    before { allow(subject).to receive(:tutor_user?).and_return(false) }
    it { should_not validate_presence_of(:name_url) }
    it { should_not validate_presence_of(:tutor_link) }
  end

  context 'user email validation' do
    before do
      user_group = FactoryBot.create(:student_user_group)
      @user = FactoryBot.create(:user, user_group_id: user_group.id)
    end

    it 'validates uniqueness of email' do
      expect(@user).to validate_uniqueness_of(:email).case_insensitive
    end
  end

  it { should validate_inclusion_of(:locale).in_array(User::LOCALES) }

  # callbacks
  it { should callback(:add_guid).before(:create) }
  it { should callback(:create_referral_code_record).after(:create) }
  it { should callback(:update_stripe_customer).after(:update) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(User).to respond_to(:all_in_order) }
  it { expect(User).to respond_to(:sort_by_email) }
  it { expect(User).to respond_to(:sort_by_name) }
  it { expect(User).to respond_to(:sort_by_most_recent) }
  it { expect(User).to respond_to(:sort_by_recent_registration) }
  it { expect(User).to respond_to(:this_month) }
  it { expect(User).to respond_to(:this_week) }
  it { expect(User).to respond_to(:active_this_week) }
  it { expect(User).to respond_to(:with_course_tutors) }

  # class methods
  it { expect(User).to respond_to(:search) }
  it { expect(User).to respond_to(:all_students) }
  it { expect(User).to respond_to(:all_trial_or_sub_students) }
  it { expect(User).to respond_to(:all_tutors) }
  it { expect(User).to respond_to(:start_password_reset_process) }
  it { expect(User).to respond_to(:resend_pw_reset_email) }
  it { expect(User).to respond_to(:finish_password_reset_process) }
  it { expect(User).to respond_to(:sort_by) }
  it { expect(User).to respond_to(:to_csv) }
  it { expect(User).to respond_to(:to_csv_with_enrollments) }
  it { expect(User).to respond_to(:to_csv_with_visits) }
  it { expect(User).to respond_to(:parse_csv) }
  it { expect(User).to respond_to(:bulk_create) }
  it { expect(User).to respond_to(:create_csv_user) }

  # instance methods
  it { should respond_to(:student_user?) }
  it { should respond_to(:non_student_user?) }
  it { should respond_to(:standard_student_user?) }
  it { should respond_to(:bank_transfer_user?) }
  it { should respond_to(:complimentary_user?) }
  it { should respond_to(:blocked_user?) }
  it { should respond_to(:system_requirements_access?) }
  it { should respond_to(:content_management_access?) }
  it { should respond_to(:stripe_management_access?) }
  it { should respond_to(:user_management_access?) }
  it { should respond_to(:developer_access?) }
  it { should respond_to(:marketing_resources_access?) }
  it { should respond_to(:user_group_management_access?) }

  it { should respond_to(:default_card) }

  it { should respond_to(:enrolled_course?) }
  it { should respond_to(:enrolled_in_course?) }

  it { should respond_to(:referred_user?) }
  it { should respond_to(:valid_order_ids) }
  it { should respond_to(:valid_orders?) }
  it { should respond_to(:purchased_products) }

  it { should respond_to(:change_the_password) }
  it { should respond_to(:activate_user) }
  it { should respond_to(:validate_user) }
  it { should respond_to(:generate_email_verification_code) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:enrolled_courses) }
  it { should respond_to(:valid_enrolled_courses) }
  it { should respond_to(:visit_campaigns) }
  it { should respond_to(:visit_sources) }
  it { should respond_to(:visit_landing_pages) }
  it { should respond_to(:valid_enrollments_in_sitting_order) }
  it { should respond_to(:expired_enrollments_in_sitting_order) }
  it { should respond_to(:active_enrollments_in_sitting_order) }
  it { should respond_to(:next_enrollment) }
  it { should respond_to(:next_exam_date) }

  it { should respond_to(:subscription_action_required?) }
  it { should respond_to(:actionable_invoice) }

  it { should respond_to(:completed_course_step) }
  it { should respond_to(:started_course_step) }
  it { should respond_to(:last_subscription) }
  it { should respond_to(:onboarding_state) }
  it { should respond_to(:total_revenue) }

  describe 'scopes' do
    describe 'all_students' do
      let(:student) { create(:student_user) }
      let(:non_student) { create(:admin_user) }

      it 'calls the relevant scope' do
        expect(User.all_students).to include(student)
        expect(User.all_students).not_to include(non_student)
      end
    end

    describe 'all_trial_or_sub_students' do
      let(:student) { create(:student_user) }
      let(:comp_user) { create(:comp_user) }

      it 'calls the relevant scope' do
        expect(User.all_trial_or_sub_students).to include(student)
        expect(User.all_trial_or_sub_students).not_to include(comp_user)
      end
    end

    describe 'all_tutors' do
      let(:student) { create(:student_user) }
      let(:tutor) { create(:tutor_user) }

      it 'calls the relevant scope' do
        expect(User.all_tutors).to include(tutor)
        expect(User.all_tutors).not_to include(student)
      end
    end
  end

  describe 'Class Methods' do
    describe '.search' do
      let(:example_user) { create(:user) }

      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
        create(:subscription, user: example_user, paypal_subscription_guid: 'I-testGuid1234567')
      end

      it 'returns the correct user for a PayPal subscription' do
        expect(User.search('I-test').first.id).to eq example_user.id
      end
    end

    describe '.get_and_verify' do
      before do
        allow_any_instance_of(HubSpot::Contacts).to receive(:batch_create).and_return(:ok)
      end

      it 'returns NIL unless a matching user can be found' do
        expect(User.get_and_verify('test_code', 1)).to be_nil
      end

      describe 'with a matching user' do
        before :each do
          allow_any_instance_of(HubSpot::Contacts).to receive(:batch_create).and_return(:ok)
          allow_any_instance_of(HubSpot::FormContacts).to receive(:create).and_return(:ok)
        end

        let!(:test_user) { create(:user, active: false, country: nil) }

        it 'returns the matching user object' do
          expect(User.get_and_verify(test_user.email_verification_code, 1).id).to equal test_user.id
        end

        it 'calls #verify on the user object' do
          expect_any_instance_of(User).to receive(:verify)

          User.get_and_verify(test_user.email_verification_code, 1)
        end
      end
    end

    describe '.sort_by' do
      it 'calls .all_in_order unless the sort option is whitelisted' do
        expect(User).to receive(:all_in_order)

        User.sort_by('zip_code')
      end

      it 'calls .all_in_order when user_group is passed as the sort key' do
        expect(User).to receive(:all_in_order)

        User.sort_by('user_group')
      end

      it 'calls .sort_by_name when name is passed as the sort key' do
        expect(User).to receive(:sort_by_name)

        User.sort_by('name')
      end

      it 'calls .sort_by_email when email is passed as the sort key' do
        expect(User).to receive(:sort_by_email)

        User.sort_by('email')
      end

      it 'calls .sort_by_recent_registration when created is passed as the sort_key' do
        expect(User).to receive(:sort_by_recent_registration)

        User.sort_by('created')
      end
    end

    describe '.to_csv' do
      it 'calls .generate on CSV and passed any options' do
        expect(CSV).to receive(:generate).with({})

        User.to_csv
      end

      it 'returns a CSV file' do
        create(:student_user)

        expect(User.to_csv).to be_kind_of String
      end
    end

    describe '.to_csv_with_enrollments' do
      it 'calls .to_csv with the correct options' do
        expect(User).to receive(:to_csv).with({}, %w[first_name last_name email student_number date_of_birth enrolled_courses valid_enrolled_courses])

        User.to_csv_with_enrollments
      end
    end

    describe '.to_csv_with_visits' do
      it 'calls .to_csv with the correct options' do
        expect(User).to receive(:to_csv).with({}, %w[email id visit_campaigns visit_sources visit_landing_pages])

        User.to_csv_with_visits
      end
    end
  end

  describe 'Instance Methods' do
    let(:user) { create(:user) }

    describe '#check_country' do
      it 'calls the UserCountryWorker' do
        expect(UserCountryWorker).to receive(:perform_async)

        user.check_country('113.444.555')
      end
    end

    describe '#name' do
      it 'returns the first name and surname' do
        tt = build_stubbed(:user, first_name: 'Sexy', last_name: 'Giordano')

        expect(tt.name).to eq 'Sexy Giordano'
      end
    end

    describe '#default_card' do
      before :each do
        create(:subscription_payment_card, user: user, status: 'card-live', is_default_card: true)
      end

      it 'calls find on subscription_payment_cards' do
        expect(user.default_card).not_to be_nil
      end
    end

    describe '#viewable_subscriptions' do
      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      end

      context 'for in-active exam bodies' do
        let(:bad_exam_body) { create(:exam_body, active: false) }
        let(:sub_plan)      { create(:subscription_plan, exam_body_id: bad_exam_body.id) }
        let(:subscription)  { create(:subscription, state: :active, user_id: user.id, subscription_plan_id: sub_plan.id) }

        it 'does not return active subscriptions' do
          expect(user.viewable_subscriptions.count).to eq 0
        end
      end

      context 'for active exam bodies' do
        let(:good_exam_body) { create(:exam_body) }
        let(:sub_plan) { create(:subscription_plan, exam_body_id: good_exam_body.id) }

        it 'returns active subscriptions' do
          subscription = create(
            :subscription,
            state: :active,
            user_id: user.id,
            subscription_plan_id: sub_plan.id
          )

          expect(user.viewable_subscriptions.count).to eq 1
        end

        it 'returns paused subscriptions' do
          subscription = create(
            :subscription,
            state: :paused,
            user_id: user.id,
            subscription_plan_id: sub_plan.id
          )

          expect(user.viewable_subscriptions.count).to eq 1
        end

        it 'returns errored subscriptions' do
          subscription = create(
            :subscription,
            state: :errored,
            user_id: user.id,
            subscription_plan_id: sub_plan.id
          )

          expect(user.viewable_subscriptions.count).to eq 1
        end

        it 'returns pending_cancellation subscriptions' do
          subscription = create(
            :subscription,
            state: :pending_cancellation,
            user_id: user.id,
            subscription_plan_id: sub_plan.id
          )

          expect(user.viewable_subscriptions.count).to eq 1
        end

        it 'returns cancelled subscriptions' do
          subscription = create(
            :subscription,
            state: :cancelled,
            user_id: user.id,
            subscription_plan_id: sub_plan.id
          )

          expect(user.viewable_subscriptions.count).to eq 1
        end

        it 'does not return pending subscriptions' do
          subscription = create(
            :subscription,
            state: :pending,
            user_id: user.id,
            subscription_plan_id: sub_plan.id
          )

          expect(user.viewable_subscriptions.count).to eq 0
        end
      end
    end

    describe '#valid_order_ids' do
      before :each do
        create(:order, :for_stripe, user: user, stripe_status: 'paid')
        create(:order, :for_stripe, user: user, stripe_status: 'created')
      end

      it 'only returns paid orders' do
        expect(user.valid_order_ids.count).to eq 1
      end
    end

    describe '#valid_orders?' do
      it 'returns TRUE if there are valid orders' do
        create(:order, :for_stripe, user: user, stripe_status: 'paid')
        expect(user.valid_orders?).to be true
      end

      it 'returns FALSE if there are no valid orders' do
        create(:order, :for_stripe, user: user, stripe_status: 'created')
        expect(user.valid_orders?).to be false
      end
    end

    describe '.last_subscription' do
      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      end

      context 'for in-active exam bodies' do
        let(:bad_exam_body) { create(:exam_body, active: false) }
        let(:sub_plan)      { create(:subscription_plan, exam_body_id: bad_exam_body.id) }
        let!(:subscription) { create(:subscription, state: :active, user_id: user.id, subscription_plan_id: sub_plan.id) }

        it 'does not return active subscriptions' do
          expect(user.last_subscription).to eq (subscription)
        end
      end
    end

    describe '.update_hub_spot_data' do
      let(:user)   { build(:user) }
      let(:worker) { HubSpotContactWorker }

      before do
        Sidekiq::Testing.fake!
        Sidekiq::Worker.clear_all
        allow_any_instance_of(HubSpot::Contacts).to receive(:batch_create).and_return(:ok)
        allow_any_instance_of(HubSpot::FormContacts).to receive(:create).and_return(:ok)
      end

      after do
        Sidekiq::Worker.drain_all
      end

      context 'when user has updated data' do
        it 'create a job in HubSpotContactWorker' do
          user.update(first_name: Faker::Name.first_name)

          expect { worker.perform_async(rand(10)) }.to change(worker.jobs, :size).by(1)
        end
      end

      context 'when user has not updated data' do
        it 'do not create a job in HubSpotContactWorker' do
          user.update(last_request_at: Time.now)

          expect { worker.perform_async(rand(10)) }.to change(worker.jobs, :size).by(1)
        end
      end
    end

    describe '#parse_csv' do
      it 'parser a user csv file' do
        data        = File.read(Rails.root.join('spec/support/fixtures/file.csv'))
        data_users  = data.split("\n")
        data_parsed = User.parse_csv(data)
        rand_count  = rand(0..9)

        expect(data_users[rand_count].split(',').first).to eq(data_parsed[rand_count].email)
        expect(data_users[rand_count].split(',').second).to eq(data_parsed[rand_count].first_name)
        expect(data_users[rand_count].split(',').third).to eq(data_parsed[rand_count].last_name)
      end
    end

    describe '#currency_locked?' do
      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      end

      it 'returns FALSE if there are no Stripe subscriptions or orders for a user' do
        expect(user.currency_locked?).to be_falsy
      end

      it 'returns TRUE if there are any Stripe subscriptions' do
        create(:stripe_subscription, user: user)

        expect(user.currency_locked?).to be_truthy
      end

      it 'returns TRUE if there are any Stripe orders' do
        create(:order, :for_stripe, user: user)

        expect(user.currency_locked?).to be_truthy
      end
    end

    describe '#create_stripe_customer' do
      it 'calls the StripeCustomerCreationWorker' do
        expect(StripeCustomerCreationWorker).to receive(:perform_async).with(user.id)

        user.create_stripe_customer
      end
    end

    describe 'visit_elements' do
      it 'returns an array' do
        expect(user.visit_elements('test')).to be_kind_of Array
      end
    end

    describe 'visit_campaigns' do
      it 'calls visit_elements with :utm_campaign' do
        expect(user).to receive(:visit_elements).with(:utm_campaign)

        user.visit_campaigns
      end
    end

    describe 'visit_sources' do
      it 'calls visit_elements with :utm_campaign' do
        expect(user).to receive(:visit_elements).with(:utm_source)

        user.visit_sources
      end
    end

    describe 'visit_landing_pages' do
      it 'calls visit_elements with :utm_campaign' do
        expect(user).to receive(:visit_elements).with(:landing_page)

        user.visit_landing_pages
      end
    end

    describe '#verify' do
      let!(:user) { create(:user, active: false, country: nil) }

      it 'updates the relevant activation attributes' do
        expect(user.active).to be false
        expect(user.account_activated_at).to be nil
        expect(user.account_activation_code).not_to be nil

        user.verify(1)

        user.reload
        expect(user.active).to be true
        expect(user.account_activated_at).to be > 1.minute.ago
        expect(user.account_activation_code).to be nil
      end

      it 'skips account activation updates if they are already completed' do
        user.update(active: true)
        expect { user.verify(1) }.not_to change { user.account_activated_at }
      end

      it 'updates the email verification attributes' do
        expect(user.email_verified).to be false
        expect(user.email_verified_at).to be nil
        expect(user.country_id).to be nil

        user.verify(1)

        user.reload
        expect(user.email_verified).to be true
        expect(user.email_verified_at).to be > 1.minute.ago
        expect(user.country_id).to be 1
      end

      it 'skips email verification updates if they are already completed' do
        user.update(email_verified: true)
        expect { user.verify(1) }.not_to change { user.email_verified_at }
      end
    end

    describe '#validate_user' do
      let(:user) { build_stubbed(:user, email_verification_code: 'test') }

      it 'sets the correct variables on the user object' do
        expect(user.email_verified).to be false
        expect(user.email_verified_at).to be_nil
        expect(user.email_verification_code).not_to be_nil

        user.validate_user

        expect(user.email_verified).to be true
        expect(user.email_verified_at).to be_within(2.seconds).of(Time.zone.now)
        expect(user.email_verification_code).to be_nil
      end
    end

    describe '#generate_email_verification_code' do
      let(:user) { build_stubbed(:basic_student) }

      it 'sets the correct variables on the user object' do
        expect(user.email_verified).to be true
        expect(user.email_verified_at).not_to be_nil
        expect(user.email_verification_code).to be_nil

        user.generate_email_verification_code

        expect(user.email_verified).to be false
        expect(user.email_verified_at).to be_nil
        expect(user.email_verification_code).not_to be_nil
      end
    end

    describe '#full_name' do
      it 'returns the first name and surname' do
        tt = build_stubbed(:user, first_name: 'Sexy', last_name: 'Giordano')

        expect(tt.full_name).to eq 'Sexy Giordano'
      end

      it 'titelizes the first_name' do
        tt = build_stubbed(:user, first_name: 'sexy', last_name: 'Giordano')

        expect(tt.full_name).to eq 'Sexy Giordano'
      end

      it 'removes spaces between apostrophes' do
        tt = build_stubbed(:user, first_name: 'Giordano', last_name: "O' Reilly")

        expect(tt.full_name).to eq "Giordano O' Reilly"
      end
    end

    describe '#get_currency' do
      it 'returns the users currency if one is present' do
        cur = create(:currency, name: 'Aidan Dollars')
        tt = build_stubbed(:user, currency: cur)

        expect(tt.get_currency(tt.country)).to eq cur
      end

      it 'returns the default currency for the users country' do
        country = create(:country)
        tt = build_stubbed(:user, currency: nil, country: country)

        expect(tt.get_currency(tt.country)).to eq country.currency
      end
    end

    describe '#update_stripe_customer' do
      before :each do
        allow(user).to receive(:creating_hubspot_user).and_return(:ok)
        allow(Rails.env).to receive(:test?).and_return(false)
        allow(HubSpotContactWorker).to receive(:perform_async)
      end

      it 'returns NIL unless the user email has changed' do
        allow(user).to receive(:saved_change_to_email?).and_return(false)

        expect(user.send(:update_stripe_customer)).to be_nil
      end

      it 'calls #retrieve on Stripe::Customer' do
        user.stripe_customer_id = 'cus_12234555'
        customer = double(:email= => true)
        allow(customer).to receive(:save)
        expect(Stripe::Customer).to receive(:retrieve).with('cus_12234555').and_return(customer)

        user.send(:update_stripe_customer)
      end

      it 'updates the user email' do
        user.stripe_customer_id = 'cus_12234555'
        customer = double
        expect(customer).to receive(:email=).with(user.email)
        allow(customer).to receive(:save)
        allow(Stripe::Customer).to receive(:retrieve).with('cus_12234555').and_return(customer)

        user.send(:update_stripe_customer)
      end

      it 'saves the Stripe::Customer' do
        user.stripe_customer_id = 'cus_12234555'
        customer = double()
        allow(customer).to receive(:email=)
        expect(customer).to receive(:save)
        allow(Stripe::Customer).to receive(:retrieve).with('cus_12234555').and_return(customer)

        user.send(:update_stripe_customer)
      end
    end

    describe '#delete_stripe_customer' do
      before :each do
        allow(user).to receive(:creating_hubspot_user).and_return(:ok)
        allow(Rails.env).to receive(:test?).and_return(false)
        allow(HubSpotContactWorker).to receive(:perform_async)
      end

      it 'returns unless ther is a stripe_customer_id' do
        expect(user.send(:delete_stripe_customer)).to be_nil
      end

      it 'call #delete on an instance of Stripe::Customer' do
        user.stripe_customer_id = 'cus_12234555'
        expect(Stripe::Customer).to receive(:delete).with('cus_12234555').and_return(true)
        # expect(customer).to receive(:delete).with('cus_12234555')

        user.send(:delete_stripe_customer)
      end
    end

    describe '#total_revenue' do
      let(:order_value)        { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
      let(:subscription_value) { Faker::Number.decimal(l_digits: 1, r_digits: 2) }

      before :each do
        user.orders_revenue        =  order_value
        user.subscriptions_revenue =  subscription_value
      end

      it 'returns the total of orders revenue and subscriptions revenue' do
        expect(user.total_revenue).to eq(order_value + subscription_value)
      end
    end

    describe '#verify_remain_days' do
      it 'return the default days remaning to user verify email' do
        expect(user.verify_remain_days).to eq(DAYS_TO_VERIFY_EMAIL)
      end

      it 'return the 0 days remaning to user verify email' do
        user.update(created_at: 7.days.ago)
        expect(user.verify_remain_days).to eq(0)
      end
    end

    describe '#show_verify_email_message?' do
      it 'show verify email message' do
        user.update(verify_remembered_at: 7.hours.ago)
        expect(user.show_verify_email_message?).to be_truthy
      end

      it 'do not show verify email message' do
        time_now = Time.zone.now
        user.update(current_login_at: time_now, verify_remembered_at: time_now)
        expect(user.show_verify_email_message?).to be_falsey
      end
    end
  end
end
