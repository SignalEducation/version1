# == Schema Information
#
# Table name: users
#
#  id                               :integer          not null, primary key
#  email                            :string
#  first_name                       :string
#  last_name                        :string
#  address                          :text
#  country_id                       :integer
#  crypted_password                 :string(128)      default(""), not null
#  password_salt                    :string(128)      default(""), not null
#  persistence_token                :string
#  perishable_token                 :string(128)
#  single_access_token              :string
#  login_count                      :integer          default(0)
#  failed_login_count               :integer          default(0)
#  last_request_at                  :datetime
#  current_login_at                 :datetime
#  last_login_at                    :datetime
#  current_login_ip                 :string
#  last_login_ip                    :string
#  account_activation_code          :string
#  account_activated_at             :datetime
#  active                           :boolean          default(FALSE), not null
#  user_group_id                    :integer
#  password_reset_requested_at      :datetime
#  password_reset_token             :string
#  password_reset_at                :datetime
#  stripe_customer_id               :string
#  created_at                       :datetime
#  updated_at                       :datetime
#  locale                           :string
#  guid                             :string
#  trial_ended_notification_sent_at :datetime
#  crush_offers_session_id          :string
#  subscription_plan_category_id    :integer
#  password_change_required         :boolean
#  session_key                      :string
#  name_url                         :string
#  profile_image_file_name          :string
#  profile_image_content_type       :string
#  profile_image_file_size          :integer
#  profile_image_updated_at         :datetime
#  topic_interest                   :string
#  email_verification_code          :string
#  email_verified_at                :datetime
#  email_verified                   :boolean          default(FALSE), not null
#  stripe_account_balance           :integer          default(0)
#  trial_limit_in_seconds           :integer          default(0)
#  free_trial                       :boolean          default(FALSE)
#  trial_limit_in_days              :integer          default(0)
#  terms_and_conditions             :boolean          default(FALSE)
#  discourse_user                   :boolean          default(FALSE)
#  date_of_birth                    :date
#  description                      :text
#  free_trial_ended_at              :datetime
#  analytics_guid                   :string
#  student_number                   :string
#  unsubscribed_from_emails         :boolean          default(FALSE)
#

require 'rails_helper'

describe User do

  # attr-accessible
  black_list = %w(id created_at updated_at crypted_password password_salt persistence_token perishable_token single_access_token login_count failed_login_count last_request_at current_login_at last_login_at current_login_ip last_login_ip guid crush_offers_session_id subscription_plan_category_id profile_image_updated_at profile_image_file_size profile_image_content_type profile_image_file_name phone_number name_url analytics_guid discourse_user)

  User.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(User.const_defined?(:LOCALES)).to eq(true) }
  it { expect(User.const_defined?(:SORT_OPTIONS)).to eq(true) }

  # relationships
  it { should belong_to(:country) }
  it { should have_many(:course_module_element_user_logs) }
  it { should have_many(:invoices) }
  it { should have_many(:quiz_attempts) }
  it { should have_many(:subscriptions) }
  it { should have_many(:subscription_payment_cards) }
  it { should have_many(:subscription_transactions) }
  it { should have_many(:student_exam_tracks) }
  it { should belong_to(:user_group) }
  it { should have_many(:user_notifications) }
  it { should have_one(:referral_code) }
  it { should have_one(:student_access) }
  it { should have_one(:referred_signup) }
  it { should belong_to(:subscription_plan_category) }
  it { should have_and_belong_to_many(:subject_courses) }

  # validation
  context 'test uniqueness validation' do
    subject { FactoryGirl.build(:student_user) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  it { should validate_presence_of(:email) }

  it { should validate_length_of(:email).is_at_least(5).is_at_most(50) }

  it { should validate_presence_of(:first_name) }
  it { should validate_length_of(:first_name).is_at_least(2).is_at_most(20) }

  it { should validate_presence_of(:last_name) }
  it { should validate_length_of(:last_name).is_at_least(2).is_at_most(30) }

  it { should_not validate_presence_of(:topic_interest) }

  it { should validate_presence_of(:password).on(:create) }
  it { should validate_confirmation_of(:password).on(:create) }
  it { should validate_length_of(:password).is_at_least(6).is_at_most(255) }

  it { should_not validate_presence_of(:country_id) }

  it { should validate_presence_of(:user_group_id) }

  context "user email validation" do
    before do
      user_group = FactoryGirl.create(:student_user_group)
      @user = FactoryGirl.create(:user, user_group_id: user_group.id)
    end

    it "validates uniqueness of email" do
      expect(@user).to validate_uniqueness_of(:email).case_insensitive
    end
  end


  it { should validate_inclusion_of(:locale).in_array(User::LOCALES) }

  # callbacks
  it { should callback(:add_guid).before(:create) }
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:create_on_intercom).after(:commit) }
  it { should callback(:create_trial_expiration_worker).after(:commit) }

  # scopes
  it { expect(User).to respond_to(:all_in_order) }
  it { expect(User).to respond_to(:search_for) }
  it { expect(User).to respond_to(:sort_by_email) }
  it { expect(User).to respond_to(:sort_by_name) }
  it { expect(User).to respond_to(:sort_by_recent_registration) }
  it { expect(User).to respond_to(:this_month) }
  it { expect(User).to respond_to(:this_week) }
  it { expect(User).to respond_to(:active_this_week) }
  it { expect(User).to respond_to(:all_free_trial) }

  # class methods
  it { expect(User).to respond_to(:all_students) }
  it { expect(User).to respond_to(:all_trial_or_sub_students) }
  it { expect(User).to respond_to(:all_tutors) }
  it { expect(User).to respond_to(:get_and_activate) }
  it { expect(User).to respond_to(:get_and_verify) }
  it { expect(User).to respond_to(:start_password_reset_process) }
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
  it { should respond_to(:trial_or_sub_user?) }
  it { should respond_to(:complimentary_user?) }
  it { should respond_to(:tutor_user?) }
  it { should respond_to(:blocked_user?) }
  it { should respond_to(:system_requirements_access?) }
  it { should respond_to(:content_management_access?) }
  it { should respond_to(:stripe_management_access?) }
  it { should respond_to(:user_management_access?) }
  it { should respond_to(:developer_access?) }
  it { should respond_to(:home_pages_access?) }
  it { should respond_to(:user_group_management_access?) }

  it { should respond_to(:trial_user?) }
  it { should respond_to(:valid_trial_user?) }
  it { should respond_to(:not_started_trial_user?) }
  it { should respond_to(:expired_trial_user?) }
  it { should respond_to(:trial_limits_valid?) }
  it { should respond_to(:trial_days_valid?) }
  it { should respond_to(:trial_seconds_valid?) }
  it { should respond_to(:trial_days_left) }
  it { should respond_to(:trial_seconds_left) }
  it { should respond_to(:trial_minutes_left) }

  it { should respond_to(:subscription_user?) }
  it { should respond_to(:valid_subscription?) }
  it { should respond_to(:canceled_pending?) }
  it { should respond_to(:canceled_member?) }
  it { should respond_to(:current_subscription) }
  it { should respond_to(:user_subscription_status) }
  it { should respond_to(:user_account_status) }
  it { should respond_to(:permission_to_see_content) }

  it { should respond_to(:referred_user) }
  it { should respond_to(:valid_order_ids) }
  it { should respond_to(:valid_orders?) }
  it { should respond_to(:purchased_products) }

  it { should respond_to(:change_the_password) }
  it { should respond_to(:activate_user) }
  it { should respond_to(:validate_user) }
  it { should respond_to(:de_activate_user) }
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

  it { should respond_to(:resubscribe_account) }
  it { should respond_to(:completed_course_module_element) }

  it { should respond_to(:started_course_module_element) }
  it { should respond_to(:update_from_stripe) }
  it { should respond_to(:create_subscription_from_stripe) }

end
