# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  email                           :string
#  first_name                      :string
#  last_name                       :string
#  address                         :text
#  country_id                      :integer
#  crypted_password                :string(128)      default(""), not null
#  password_salt                   :string(128)      default(""), not null
#  persistence_token               :string
#  perishable_token                :string(128)
#  single_access_token             :string
#  login_count                     :integer          default(0)
#  failed_login_count              :integer          default(0)
#  last_request_at                 :datetime
#  current_login_at                :datetime
#  last_login_at                   :datetime
#  current_login_ip                :string
#  last_login_ip                   :string
#  account_activation_code         :string
#  account_activated_at            :datetime
#  active                          :boolean          default(FALSE), not null
#  user_group_id                   :integer
#  password_reset_requested_at     :datetime
#  password_reset_token            :string
#  password_reset_at               :datetime
#  stripe_customer_id              :string
#  created_at                      :datetime
#  updated_at                      :datetime
#  locale                          :string
#  guid                            :string
#  subscription_plan_category_id   :integer
#  password_change_required        :boolean
#  session_key                     :string
#  name_url                        :string
#  profile_image_file_name         :string
#  profile_image_content_type      :string
#  profile_image_file_size         :bigint(8)
#  profile_image_updated_at        :datetime
#  email_verification_code         :string
#  email_verified_at               :datetime
#  email_verified                  :boolean          default(FALSE), not null
#  stripe_account_balance          :integer          default(0)
#  free_trial                      :boolean          default(FALSE)
#  terms_and_conditions            :boolean          default(FALSE)
#  date_of_birth                   :date
#  description                     :text
#  analytics_guid                  :string
#  student_number                  :string
#  unsubscribed_from_emails        :boolean          default(FALSE)
#  communication_approval          :boolean          default(FALSE)
#  communication_approval_datetime :datetime
#  preferred_exam_body_id          :bigint(8)
#  currency_id                     :bigint(8)
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
  it { should have_many(:course_module_element_user_logs) }
  it { should have_many(:completed_course_module_element_user_logs) }
  it { should have_many(:incomplete_course_module_element_user_logs) }
  it { should have_many(:course_tutor_details) }
  it { should have_many(:exam_body_user_details) }
  it { should have_many(:enrollments) }
  it { should have_many(:invoices) }
  it { should have_many(:quiz_attempts) }
  it { should have_many(:orders) }
  it { should have_many(:subscriptions) }
  it { should have_many(:subscription_payment_cards) }
  it { should have_many(:subscription_transactions) }
  it { should have_many(:student_exam_tracks) }
  it { should have_many(:course_section_user_logs) }
  it { should have_many(:subject_course_user_logs) }
  it { should belong_to(:user_group) }
  it { should have_many(:ahoy_visits) }
  it { should have_many(:charges) }
  it { should have_many(:refunds) }
  it { should have_many(:ahoy_events) }
  it { should have_one(:referral_code) }
  it { should have_one(:student_access) }
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

  context "user email validation" do
    before do
      user_group = FactoryBot.create(:student_user_group)
      @user = FactoryBot.create(:user, user_group_id: user_group.id)
    end

    it "validates uniqueness of email" do
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
  it { expect(User).to respond_to(:with_course_tutor_details) }

  # class methods
  it { expect(User).to respond_to(:search) }
  it { expect(User).to respond_to(:all_students) }
  it { expect(User).to respond_to(:all_trial_or_sub_students) }
  it { expect(User).to respond_to(:all_tutors) }
  it { expect(User).to respond_to(:get_and_verify) }
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
  it { should respond_to(:subject_course_user_log_course_ids) }
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

  it { should respond_to(:completed_course_module_element) }
  it { should respond_to(:started_course_module_element) }
  it { should respond_to(:last_subscription) }

  describe 'Methods' do
    describe '.viewable_subscriptions' do
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
  end
end
