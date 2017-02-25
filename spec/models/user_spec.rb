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
#  corporate_customer_id            :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  locale                           :string
#  guid                             :string
#  trial_ended_notification_sent_at :datetime
#  crush_offers_session_id          :string
#  subscription_plan_category_id    :integer
#  employee_guid                    :string
#  password_change_required         :boolean
#  session_key                      :string
#  first_description                :text
#  second_description               :text
#  wistia_url                       :text
#  personal_url                     :text
#  name_url                         :string
#  qualifications                   :text
#  profile_image_file_name          :string
#  profile_image_content_type       :string
#  profile_image_file_size          :integer
#  profile_image_updated_at         :datetime
#  phone_number                     :string
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
#

require 'rails_helper'

describe User do
  #Makes test - user_spec.rb:102 # User should validate that :email is case-insensitively unique pass but causes test - user_spec.rb:114 # User should validate that :password cannot be empty/falsy to fail cause it's populating the passwrd field overriding the test pre-populations
  subject { FactoryGirl.build(:individual_student_user) }

  # attr-accessible
  black_list = %w(id created_at updated_at crypted_password password_salt persistence_token perishable_token single_access_token login_count failed_login_count last_request_at current_login_at last_login_at current_login_ip last_login_ip guid crush_offers_session_id subscription_plan_category_id profile_image_updated_at profile_image_file_size profile_image_content_type profile_image_file_name phone_number discourse_user)

  User.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(User.const_defined?(:EMAIL_FREQUENCIES)).to eq(true) }
  it { expect(User.const_defined?(:LOCALES)).to eq(true) }
  it { expect(User.const_defined?(:SORT_OPTIONS)).to eq(true) }

  # relationships
  it { should belong_to(:corporate_customer) }
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
  it { should have_one(:referred_signup) }
  it { should belong_to(:subscription_plan_category) }
  it { should have_and_belong_to_many(:corporate_groups) }
  it { should have_and_belong_to_many(:subject_courses) }

  # validation
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_length_of(:email).is_at_least(7).is_at_most(50) }

  it { should validate_presence_of(:first_name) }
  it { should validate_length_of(:first_name).is_at_least(1).is_at_most(20) }

  it { should validate_presence_of(:last_name) }
  it { should validate_length_of(:last_name).is_at_least(1).is_at_most(30) }

  it { should_not validate_presence_of(:topic_interest) }

  xit { should validate_presence_of(:password).on(:create) }
  it { should validate_confirmation_of(:password).on(:create) }
  it { should validate_length_of(:password).is_at_least(6).is_at_most(255) }

  it { should_not validate_presence_of(:country_id) }

  it { should validate_presence_of(:user_group_id) }

  context "user email validation" do
    before do
      user_group = FactoryGirl.create(:individual_student_user_group)
      @user = FactoryGirl.create(:user, user_group_id: user_group.id, student_user_type_id: 1)
    end

    it "validates uniqueness of email" do
      expect(@user).to validate_uniqueness_of(:email).case_insensitive
    end
  end

  context "corporate_customer_id validation" do
    before do
      FactoryGirl.create(:individual_student_user_group)
      @corporate_student_group = FactoryGirl.create(:corporate_student_user_group)
      FactoryGirl.create(:tutor_user_group)
      FactoryGirl.create(:content_manager_user_group)
      FactoryGirl.create(:blogger_user_group)
      @corporate_customer_group = FactoryGirl.create(:corporate_customer_user_group)
      FactoryGirl.create(:site_admin_user_group)
    end

    it "does not validate presence for non-corporate users" do
      UserGroup.where(corporate_customer: false, corporate_student: false).each do |ug|
        user = FactoryGirl.create(:user, user_group_id: ug.id, student_user_type_id: 1)
        expect(user).not_to validate_presence_of(:corporate_customer_id)
      end
    end

    it "requires corporate_customer_id for corporate customer" do
      user = FactoryGirl.create(:user, user_group_id: @corporate_customer_group.id, corporate_customer_id: 1)
      expect(user).to validate_presence_of(:corporate_customer_id)
    end

    it "requires corporate_customer_id for corporate student" do
      user = FactoryGirl.create(:user, user_group_id: @corporate_student_group.id, corporate_customer_id: 1)
      expect(user).to validate_presence_of(:corporate_customer_id)
    end
  end


  it { should validate_inclusion_of(:locale).in_array(User::LOCALES) }

  xit { should validate_uniqueness_of(:employee_guid).scoped_to(:corporate_customer_id) }

  # callbacks
  it { should callback(:add_guid).before(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(User).to respond_to(:all_in_order) }
  it { expect(User).to respond_to(:search_for) }
  it { expect(User).to respond_to(:sort_by_email) }
  it { expect(User).to respond_to(:sort_by_name) }
  it { expect(User).to respond_to(:sort_by_recent_registration) }

  # class methods
  it { expect(User).to respond_to(:all_admins) }
  it { expect(User).to respond_to(:all_tutors) }
  it { expect(User).to respond_to(:get_and_activate) }
  it { expect(User).to respond_to(:start_password_reset_process) }
  it { expect(User).to respond_to(:finish_password_reset_process) }
  it { expect(User).to respond_to(:sort_by) }

  # instance methods
  it { should respond_to(:admin?) }
  it { should respond_to(:assign_anonymous_logs_to_user) }
  it { should respond_to(:change_the_password) }
  it { should respond_to(:content_manager?) }
  it { should respond_to(:corporate_customer?) }
  it { should respond_to(:corporate_student?) }
  it { should respond_to(:de_activate_user) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:full_name) }
  it { should respond_to(:individual_student?) }
  it { should respond_to(:tutor?) }

end
