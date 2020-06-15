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
#
require 'rails_helper'

describe User do
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

  context 'is a tutor' do
    before { allow(subject).to receive(:tutor_user?).and_return(true) }
    it { should validate_presence_of(:name_url)}
  end

  context 'is not a tutor' do
    before { allow(subject).to receive(:tutor_user?).and_return(false) }
    it { should_not validate_presence_of(:name_url)}
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
  it { should respond_to(:create_referral) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:full_name) }
  it { should respond_to(:this_hour) }
  it { should respond_to(:course_log_course_ids) }
  it { should respond_to(:enrolled_courses) }
  it { should respond_to(:valid_enrolled_courses) }
  it { should respond_to(:visit_campaigns) }
  it { should respond_to(:visit_sources) }
  it { should respond_to(:visit_landing_pages) }
  it { should respond_to(:enrolled_course_ids) }
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

  describe 'Methods' do
    describe '#viewable_subscriptions' do
      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      end

      let(:user) { create(:user) }

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

    describe '.last_subscription' do
      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      end

      let(:user) { create(:user) }

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
        data = File.read(Rails.root.join('spec', 'support', 'fixtures', 'file.csv'))
        data_users  = data.split("\n")
        data_parsed = User.parse_csv(data)
        rand_count  = rand(0..9)

        expect(data_users[rand_count].split(',').first).to eq(data_parsed[rand_count].email)
        expect(data_users[rand_count].split(',').second).to eq(data_parsed[rand_count].first_name)
        expect(data_users[rand_count].split(',').third).to eq(data_parsed[rand_count].last_name)
      end
    end

    describe '#currency_locked?' do
      let(:user) { create(:user) }

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
  end
end
