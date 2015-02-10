require 'rails_helper'

shared_context 'users_and_groups_setup' do

  # user groups
  let(:individual_student_user_group) { FactoryGirl.create(:individual_student_user_group) }
  let(:corporate_student_user_group) { FactoryGirl.create(:corporate_student_user_group) }
  let(:tutor_user_group) { FactoryGirl.create(:tutor_user_group) }
  let(:content_manager_user_group) { FactoryGirl.create(:content_manager_user_group) }
  let(:blogger_user_group) { FactoryGirl.create(:blogger_user_group) }
  let(:corporate_customer_user_group) { FactoryGirl.create(:corporate_customer_user_group) }
  let(:forum_manager_user_group) { FactoryGirl.create(:forum_manager_user_group) }
  let(:site_admin_user_group) { FactoryGirl.create(:site_admin_user_group) }

  # users
  let(:individual_student_user) { FactoryGirl.create(:individual_student_user,
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

end
