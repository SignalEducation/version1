# == Schema Information
#
# Table name: users
#
#  id                                       :integer          not null, primary key
#  email                                    :string
#  first_name                               :string
#  last_name                                :string
#  address                                  :text
#  country_id                               :integer
#  crypted_password                         :string(128)      default(""), not null
#  password_salt                            :string(128)      default(""), not null
#  persistence_token                        :string
#  perishable_token                         :string(128)
#  single_access_token                      :string
#  login_count                              :integer          default(0)
#  failed_login_count                       :integer          default(0)
#  last_request_at                          :datetime
#  current_login_at                         :datetime
#  last_login_at                            :datetime
#  current_login_ip                         :string
#  last_login_ip                            :string
#  account_activation_code                  :string
#  account_activated_at                     :datetime
#  active                                   :boolean          default(FALSE), not null
#  user_group_id                            :integer
#  password_reset_requested_at              :datetime
#  password_reset_token                     :string
#  password_reset_at                        :datetime
#  stripe_customer_id                       :string
#  corporate_customer_id                    :integer
#  operational_email_frequency              :string
#  study_plan_notifications_email_frequency :string
#  falling_behind_email_alert_frequency     :string
#  marketing_email_frequency                :string
#  marketing_email_permission_given_at      :datetime
#  blog_notification_email_frequency        :string
#  forum_notification_email_frequency       :string
#  created_at                               :datetime
#  updated_at                               :datetime
#  locale                                   :string
#  guid                                     :string
#  trial_ended_notification_sent_at         :datetime
#  crush_offers_session_id                  :string
#  subscription_plan_category_id            :integer
#  employee_guid                            :string
#  password_change_required                 :boolean
#  session_key                              :string
#

require 'rails_helper'

describe User do

  # attr-accessible
  black_list = %w(id created_at updated_at crypted_password password_salt persistence_token perishable_token single_access_token login_count failed_login_count last_request_at current_login_at last_login_at current_login_ip last_login_ip account_activated_at account_activation_code guid trial_ended_notification_sent_at crush_offers_session_id subscription_plan_category_id session_key)
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
  it { should have_one(:referral_code) }
  it { should have_one(:referred_signup) }
  it { should belong_to(:subscription_plan_category) }
  it { should have_and_belong_to_many(:corporate_groups) }

  # validation
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_length_of(:email).is_at_least(7).is_at_most(40) }

  it { should validate_presence_of(:first_name) }
  it { should validate_length_of(:first_name).is_at_least(2).is_at_most(20) }

  it { should validate_presence_of(:last_name) }
  it { should validate_length_of(:last_name).is_at_least(2).is_at_most(30) }

  it { should validate_presence_of(:password).on(:create) }
  it { should validate_confirmation_of(:password).on(:create) }
  it { should validate_length_of(:password).is_at_least(6).is_at_most(255) }

  it { should validate_presence_of(:country_id) }
  it { should validate_numericality_of(:country_id) }

  it { should validate_presence_of(:user_group_id) }
  it { should validate_numericality_of(:user_group_id) }

  context "corporate_customer_id validation" do
    before do
      FactoryGirl.create(:individual_student_user_group)
      @corporate_student_group = FactoryGirl.create(:corporate_student_user_group)
      FactoryGirl.create(:tutor_user_group)
      FactoryGirl.create(:content_manager_user_group)
      FactoryGirl.create(:blogger_user_group)
      @corporate_customer_group = FactoryGirl.create(:corporate_customer_user_group)
      FactoryGirl.create(:site_admin_user_group)
      FactoryGirl.create(:forum_manager_user_group)
    end

    it "does not validate presence for non-corporate users" do
      UserGroup.where(corporate_customer: false, corporate_student: false).each do |ug|
        user = FactoryGirl.create(:user, user_group_id: ug.id)
        expect(user).not_to validate_presence_of(:corporate_customer_id)
      end
    end

    it "requires corporate_customer_id for corporate customer" do
      user = FactoryGirl.create(:user, user_group_id: @corporate_customer_group.id, corporate_customer_id: 1)
      expect(user).to validate_presence_of(:corporate_customer_id)
      expect(user).to validate_numericality_of(:corporate_customer_id)
    end

    it "requires corporate_customer_id for corporate student" do
      user = FactoryGirl.create(:user, user_group_id: @corporate_student_group.id, corporate_customer_id: 1)
      expect(user).to validate_presence_of(:corporate_customer_id)
      expect(user).to validate_numericality_of(:corporate_customer_id)
    end
  end


  it { should validate_inclusion_of(:operational_email_frequency).in_array(User::EMAIL_FREQUENCIES) }
  it { should validate_length_of(:operational_email_frequency).is_at_most(255) }

  it { should validate_inclusion_of(:study_plan_notifications_email_frequency).in_array(User::EMAIL_FREQUENCIES) }
  it { should validate_length_of(:study_plan_notifications_email_frequency).is_at_most(255) }

  it { should validate_inclusion_of(:falling_behind_email_alert_frequency).in_array(User::EMAIL_FREQUENCIES) }
  it { should validate_length_of(:falling_behind_email_alert_frequency).is_at_most(255) }

  it { should validate_inclusion_of(:marketing_email_frequency).in_array(User::EMAIL_FREQUENCIES) }
  it { should validate_length_of(:marketing_email_frequency).is_at_most(255) }

  it { should validate_inclusion_of(:blog_notification_email_frequency).in_array(User::EMAIL_FREQUENCIES) }
  it { should validate_length_of(:blog_notification_email_frequency).is_at_most(255) }

  it { should validate_inclusion_of(:forum_notification_email_frequency).in_array(User::EMAIL_FREQUENCIES) }
  it { should validate_length_of(:forum_notification_email_frequency).is_at_most(255) }

  it { should validate_inclusion_of(:locale).in_array(User::LOCALES) }

  it { should validate_uniqueness_of(:employee_guid).scoped_to(:corporate_customer_id) }

  # callbacks
  it { should callback(:set_defaults).before(:validation).on(:create) }
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
  it { should respond_to(:frequent_forum_user?) }
  it { should respond_to(:full_name) }
  it { should respond_to(:individual_student?) }
  it { should respond_to(:tutor?) }

  context "compulsory and restricted levels and sections" do
    before do
      @corporate_student_user_group = FactoryGirl.create(:corporate_student_user_group)

      @junior_group = FactoryGirl.create(:corporate_group)
      @senior_group = FactoryGirl.create(:corporate_group)

      @exam_levels = FactoryGirl.create_list(:active_exam_level, 3, live: true)
      @junior_group.corporate_group_grants.create(exam_level_id: @exam_levels[0].id, restricted: true)
      @junior_group.corporate_group_grants.create(exam_level_id: @exam_levels[1].id, restricted: true)
      @senior_group.corporate_group_grants.create(exam_level_id: @exam_levels[1].id, compulsory: true)
      @senior_group.corporate_group_grants.create(exam_level_id: @exam_levels[2].id, compulsory: true)

      @exam_sections = FactoryGirl.create_list(:active_exam_section, 4, live: true)
      @junior_group.corporate_group_grants.create(exam_section_id: @exam_sections[0].id, restricted: true)
      @junior_group.corporate_group_grants.create(exam_section_id: @exam_sections[1].id, restricted: true)
      @junior_group.corporate_group_grants.create(exam_section_id: @exam_sections[2].id, restricted: true)
      @senior_group.corporate_group_grants.create(exam_section_id: @exam_sections[1].id, compulsory: true)
      @senior_group.corporate_group_grants.create(exam_section_id: @exam_sections[2].id, compulsory: true)
      @senior_group.corporate_group_grants.create(exam_section_id: @exam_sections[3].id, compulsory: true)
    end

    context 'non-corporate student' do
      it 'returns empty arrays for compulsory and restricted exam levels and sections' do
        corporate_customer = FactoryGirl.create(:corporate_customer)
        student = FactoryGirl.create(:individual_student_user, corporate_customer_id: corporate_customer.id)
        expect(student.compulsory_exam_level_ids.length).to eq(0)
        expect(student.compulsory_exam_section_ids.length).to eq(0)
        expect(student.restricted_exam_level_ids.length).to eq(0)
        expect(student.restricted_exam_section_ids.length).to eq(0)
      end
    end

    context "single group membership" do
      before do
        @junior = FactoryGirl.create(:corporate_student_user, user_group_id: @corporate_student_user_group.id)
        @junior.corporate_group_ids = [@junior_group.id]

        @senior = FactoryGirl.create(:corporate_student_user, user_group_id: @corporate_student_user_group.id)
        @senior.corporate_group_ids = [@senior_group.id]
      end

      it 'returns all compulsory exam levels' do
        expect(@junior.compulsory_exam_level_ids.length).to eq(0)
        expect(@senior.compulsory_exam_level_ids.length).to eq(@senior_group
                                                             .corporate_group_grants
                                                             .where('exam_level_id is not null')
                                                             .where(exam_section_id: nil)
                                                             .count)
        expect(@senior.compulsory_exam_level_ids.sort).to eq(@senior_group
                                                             .corporate_group_grants
                                                             .where('exam_level_id is not null')
                                                             .where(exam_section_id: nil)
                                                             .pluck(:exam_level_id)
                                                             .sort)
      end

      it 'returns all compulsory exam sections' do
        expect(@junior.compulsory_exam_section_ids.length).to eq(0)
        expect(@senior.compulsory_exam_section_ids.length).to eq(@senior_group
                                                               .corporate_group_grants
                                                               .where('exam_section_id is not null')
                                                               .count)
        expect(@senior.compulsory_exam_section_ids.sort).to eq(@senior_group
                                                                .corporate_group_grants
                                                                .where('exam_section_id is not null')
                                                                .pluck(:exam_section_id)
                                                                .sort)
      end

      it 'returns all restricted exam levels' do
        expect(@junior.restricted_exam_level_ids.length).to eq(@junior_group
                                                             .corporate_group_grants
                                                             .where('exam_level_id is not null')
                                                             .where(exam_section_id: nil)
                                                             .count)
        expect(@junior.restricted_exam_level_ids.sort).to eq(@junior_group
                                                              .corporate_group_grants
                                                              .where('exam_level_id is not null')
                                                              .where(exam_section_id: nil)
                                                              .pluck(:exam_level_id)
                                                              .sort)
        expect(@senior.restricted_exam_level_ids.length).to eq(0)
      end

      it 'returns all restricted exam sections' do
        expect(@junior.restricted_exam_section_ids.length).to eq(@junior_group
                                                               .corporate_group_grants
                                                               .where('exam_section_id is not null')
                                                               .count)
        expect(@junior.restricted_exam_section_ids.sort).to eq(@junior_group
                                                                .corporate_group_grants
                                                                .where('exam_section_id is not null')
                                                                .pluck(:exam_section_id)
                                                                .sort)
        expect(@senior.restricted_exam_section_ids.length).to eq(0)
      end
    end

    context "multiple group membership" do
      before do
        @corporate_student = FactoryGirl.create(:corporate_student_user, user_group_id: @corporate_student_user_group.id)
        @corporate_student.corporate_group_ids = [@junior_group.id, @senior_group.id]
      end

      it 'returns all compulsory exam levels' do
        expect(@corporate_student.compulsory_exam_level_ids.length).to eq(@senior_group
                                                                           .corporate_group_grants
                                                                           .where('exam_level_id is not null')
                                                                           .where(exam_section_id: nil)
                                                                           .count)
        expect(@corporate_student.compulsory_exam_level_ids.sort).to eq(@senior_group
                                                                         .corporate_group_grants
                                                                         .where('exam_level_id is not null')
                                                                         .where(exam_section_id: nil)
                                                                         .pluck(:exam_level_id)
                                                                         .sort)
      end

      it 'returns all compulsory exam sections' do
        expect(@corporate_student.compulsory_exam_section_ids.length).to eq(@senior_group
                                                                             .corporate_group_grants
                                                                             .where('exam_section_id is not null')
                                                                             .count)
        expect(@corporate_student.compulsory_exam_section_ids.sort).to eq(@senior_group
                                                                           .corporate_group_grants
                                                                           .where('exam_section_id is not null')
                                                                           .pluck(:exam_section_id)
                                                                           .sort)
      end

      it 'returns all restricted exam levels' do
        expect(@corporate_student.restricted_exam_level_ids.length).to eq(1)
        expect(@corporate_student.restricted_exam_level_ids[0]).to eq(@exam_levels[0].id)
      end

      it 'returns all restricted exam sections' do
        expect(@corporate_student.restricted_exam_section_ids.length).to eq(1)
        expect(@corporate_student.restricted_exam_section_ids[0]).to eq(@exam_sections[0].id)
      end
    end
  end
end
