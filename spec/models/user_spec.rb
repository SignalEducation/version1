# == Schema Information
#
# Table name: users
#
#  id                                       :integer          not null, primary key
#  email                                    :string(255)
#  first_name                               :string(255)
#  last_name                                :string(255)
#  address                                  :text
#  country_id                               :integer
#  crypted_password                         :string(128)      default(""), not null
#  password_salt                            :string(128)      default(""), not null
#  persistence_token                        :string(255)
#  perishable_token                         :string(128)
#  single_access_token                      :string(255)
#  login_count                              :integer          default(0)
#  failed_login_count                       :integer          default(0)
#  last_request_at                          :datetime
#  current_login_at                         :datetime
#  last_login_at                            :datetime
#  current_login_ip                         :string(255)
#  last_login_ip                            :string(255)
#  account_activation_code                  :string(255)
#  account_activated_at                     :datetime
#  active                                   :boolean          default(FALSE), not null
#  user_group_id                            :integer
#  password_reset_requested_at              :datetime
#  password_reset_token                     :string(255)
#  password_reset_at                        :datetime
#  stripe_customer_id                       :string(255)
#  corporate_customer_id                    :integer
#  corporate_customer_user_group_id         :integer
#  operational_email_frequency              :string(255)
#  study_plan_notifications_email_frequency :string(255)
#  falling_behind_email_alert_frequency     :string(255)
#  marketing_email_frequency                :string(255)
#  marketing_email_permission_given_at      :datetime
#  blog_notification_email_frequency        :string(255)
#  forum_notification_email_frequency       :string(255)
#  created_at                               :datetime
#  updated_at                               :datetime
#  locale                                   :string(255)
#  guid                                     :string(255)
#

require 'rails_helper'

describe User do

  # attr-accessible
  black_list = %w(id created_at updated_at crypted_password password_salt persistence_token perishable_token single_access_token login_count failed_login_count last_request_at current_login_at last_login_at current_login_ip last_login_ip account_activated_at account_activation_code address guid)
  User.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(User.const_defined?(:EMAIL_FREQUENCIES)).to eq(true) }

  # relationships
  it { should belong_to(:corporate_customer) }
  it { should have_many(:owned_corporate_accounts) }
  xit { should belong_to(:corporate_customer_user_group) }
  it { should belong_to(:country) }
  it { should have_many(:course_modules) }
  it { should have_many(:course_module_element_user_logs) }
  it { should have_many(:forum_posts) }
  it { should have_many(:forum_post_concerns) }
  it { should have_many(:forum_topic_users) }
  it { should have_many(:institution_users) }
  it { should have_many(:invoices) }
  it { should have_many(:quiz_attempts) }
  it { should have_many(:created_static_pages) }
  it { should have_many(:updated_static_pages) }
  it { should have_many(:subscriptions) }
  it { should have_many(:subscription_payment_cards) }
  it { should have_many(:subscription_transactions) }
  it { should have_many(:student_exam_tracks) }
  it { should have_many(:user_exam_level) }
  it { should have_many(:user_activity_logs) }
  it { should belong_to(:user_group) }
  it { should have_many(:user_likes) }
  it { should have_many(:user_notifications) }

  # validation
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }

  it { should validate_presence_of(:first_name) }
  it { should ensure_length_of(:first_name).is_at_least(2).is_at_most(20) }

  it { should validate_presence_of(:last_name) }

  it { should validate_presence_of(:password).on(:create) }
  it { should validate_confirmation_of(:password).on(:create) }

  it { should validate_presence_of(:country_id) }
  it { should validate_numericality_of(:country_id) }

  it { should validate_presence_of(:user_group_id) }
  it { should validate_numericality_of(:user_group_id) }

  it { should_not validate_presence_of(:corporate_customer_id) }
  it { should validate_numericality_of(:corporate_customer_id) }

  it { should_not validate_presence_of(:corporate_customer_user_group_id) }
  it { should validate_numericality_of(:corporate_customer_user_group_id) }

  it { should validate_inclusion_of(:operational_email_frequency).in_array(User::EMAIL_FREQUENCIES) }

  it { should validate_inclusion_of(:study_plan_notifications_email_frequency).in_array(User::EMAIL_FREQUENCIES) }

  it { should validate_inclusion_of(:falling_behind_email_alert_frequency).in_array(User::EMAIL_FREQUENCIES) }

  it { should validate_inclusion_of(:marketing_email_frequency).in_array(User::EMAIL_FREQUENCIES) }

  it { should validate_inclusion_of(:blog_notification_email_frequency).in_array(User::EMAIL_FREQUENCIES) }

  it { should validate_inclusion_of(:forum_notification_email_frequency).in_array(User::EMAIL_FREQUENCIES) }

  it { should validate_inclusion_of(:locale).in_array(User::LOCALES) }

  # callbacks
  it { should callback(:set_defaults).before(:validation).on(:create) }
  it { should callback(:de_activate_user).before(:validation).on(:create) }
  it { should callback(:add_guid).before(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(User).to respond_to(:all_in_order) }

  # class methods
  it { expect(User).to respond_to(:all_admins) }
  it { expect(User).to respond_to(:all_tutors) }
  it { expect(User).to respond_to(:get_and_activate) }
  it { expect(User).to respond_to(:start_password_reset_process) }
  it { expect(User).to respond_to(:finish_password_reset_process) }

  # instance methods
  it { should respond_to(:admin?) }
  it { should respond_to(:change_the_password) }
  it { should respond_to(:content_manager?) }
  it { should respond_to(:corporate_customer?) }
  it { should respond_to(:corporate_student?) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:frequent_forum_user?) }
  it { should respond_to(:full_name) }
  it { should respond_to(:individual_student?) }
  it { should respond_to(:tutor?) }

end
