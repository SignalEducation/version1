require 'rails_helper'

shared_context 'users_and_groups_setup' do


  # users
  let!(:student_user) { FactoryGirl.create(:student_user, user_group_id: student_user_group.id) }
  let(:student_access_1) { FactoryGirl.create(:valid_trial_student_access, user_id: student_user.id) }

  let(:inactive_student_user) { FactoryGirl.create(:inactive_student_user , user_group_id: student_user_group.id) }
  let(:unverified_student_user) { FactoryGirl.create(:unverified_user, user_group_id: student_user_group.id) }
  let(:tutor_user) { FactoryGirl.create(:tutor_user, user_group_id: tutor_user_group.id) }
  let(:content_manager_user) { FactoryGirl.create(:content_manager_user, user_group_id: content_manager_user_group.id) }
  let(:blogger_user) { FactoryGirl.create(:blogger_user, user_group_id: blogger_user_group.id) }
  let(:comp_user) { FactoryGirl.create(:comp_user, user_group_id: complimentary_user_group.id) }
  let(:unverified_comp_user) { FactoryGirl.create(:unverified_comp_user, user_group_id: complimentary_user_group.id) }
  let(:customer_support_manager_user) { FactoryGirl.create(:customer_support_manager_user, user_group_id: customer_support_user_group.id) }
  let(:marketing_manager_user) { FactoryGirl.create(:marketing_manager_user, user_group_id: marketing_manager_user_group.id) }
  let(:admin_user) { FactoryGirl.create(:admin_user, user_group_id: admin_user_group.id) }

  let(:user_list) {[student_user, admin_user, tutor_user, content_manager_user, comp_user, customer_support_manager_user, marketing_manager_user] }

end
