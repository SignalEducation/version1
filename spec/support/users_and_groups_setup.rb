require 'rails_helper'

shared_context 'users_and_groups_setup' do

  let!(:currency) { FactoryGirl.create(:euro)}
  let!(:country) { FactoryGirl.create(:ireland, currency_id: currency.id) }

  let!(:corporate_organisation) { FactoryGirl.create(:corporate_customer) }

  # user groups
  let!(:individual_student_user_group) { FactoryGirl.create(:individual_student_user_group) }
  let(:corporate_student_user_group) { FactoryGirl.create(:corporate_student_user_group) }
  let(:tutor_user_group) { FactoryGirl.create(:tutor_user_group) }
  let(:content_manager_user_group) { FactoryGirl.create(:content_manager_user_group) }
  let(:blogger_user_group) { FactoryGirl.create(:blogger_user_group) }
  let(:forum_manager_user_group) { FactoryGirl.create(:forum_manager_user_group) }
  let(:site_admin_user_group) { FactoryGirl.create(:site_admin_user_group) }
  let(:corporate_customer_user_group) { FactoryGirl.create(:corporate_customer_user_group) }

  # user types
  let!(:free_trial_user_type) { FactoryGirl.create(:free_trial_user_type) }
  let(:subscription_user_type) { FactoryGirl.create(:subscription_user_type) }
  let(:product_user_type) { FactoryGirl.create(:product_user_type) }
  let(:sub_and_product_user_type) { FactoryGirl.create(:sub_and_product_user_type) }
  let(:trial_and_product_user_type) { FactoryGirl.create(:trial_and_product_user_type) }
  let(:no_access_user_type) { FactoryGirl.create(:no_access_user_type) }

  # users
  let!(:individual_student_user) { FactoryGirl.create(:individual_student_user,
                                user_group_id: individual_student_user_group.id) }
  let(:inactive_individual_student_user) { FactoryGirl.create(:inactive_individual_student_user,
                                user_group_id: individual_student_user_group.id) }
  let(:corporate_student_user) { FactoryGirl.create(:corporate_student_user,
                                user_group_id: corporate_student_user_group.id) }
  let(:tutor_user) { FactoryGirl.create(:tutor_user,
                                user_group_id: tutor_user_group.id) }
  let(:content_manager_user) { FactoryGirl.create(:content_manager_user,
                                user_group_id: content_manager_user_group.id) }
  let(:blogger_user) { FactoryGirl.create(:blogger_user,
                                user_group_id: blogger_user_group.id) }
  let(:corporate_customer_user) { FactoryGirl.create(:corporate_customer_user,
                                user_group_id: corporate_customer_user_group.id) }
  let(:forum_manager_user) { FactoryGirl.create(:forum_manager_user,
                                user_group_id: forum_manager_user_group.id) }
  let(:admin_user) { FactoryGirl.create(:admin_user,
                                user_group_id: site_admin_user_group.id) }

  let(:user_list) { [free_trial_student, subscription_student, product_student, sub_and_product_student, trial_and_product_student, no_access_student, admin_user, tutor_user, content_manager_user, blogger_user, forum_manager_user, corporate_customer_user, corporate_student_user] }

  # student_type users
  let!(:free_trial_student) { FactoryGirl.create(:active_individual_student_user, user_group_id: individual_student_user_group.id, student_user_type_id: free_trial_user_type.id) }
  let!(:subscription_student) { FactoryGirl.create(:active_individual_student_user, user_group_id: individual_student_user_group.id, student_user_type_id: subscription_user_type.id) }
  let!(:product_student) { FactoryGirl.create(:active_individual_student_user, user_group_id: individual_student_user_group.id, student_user_type_id: product_user_type.id) }
  let!(:sub_and_product_student) { FactoryGirl.create(:active_individual_student_user, user_group_id: individual_student_user_group.id, student_user_type_id: sub_and_product_user_type.id) }
  let!(:trial_and_product_student) { FactoryGirl.create(:active_individual_student_user, user_group_id: individual_student_user_group.id, student_user_type_id: trial_and_product_user_type.id) }
  let!(:no_access_student) { FactoryGirl.create(:active_individual_student_user, user_group_id: individual_student_user_group.id, student_user_type_id: no_access_user_type.id) }

  let(:student_type_list) { [free_trial_student, subscription_student, product_student, sub_and_product_student, trial_and_product_student, no_access_student] }

end
