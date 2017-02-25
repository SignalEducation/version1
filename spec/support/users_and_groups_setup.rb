require 'rails_helper'

shared_context 'users_and_groups_setup' do

  let!(:corporate_organisation) { FactoryGirl.create(:corporate_customer) }

  # user groups
  let!(:individual_student_user_group) { FactoryGirl.create(:individual_student_user_group) }
  let(:corporate_student_user_group) { FactoryGirl.create(:corporate_student_user_group) }
  let(:tutor_user_group) { FactoryGirl.create(:tutor_user_group) }
  let(:content_manager_user_group) { FactoryGirl.create(:content_manager_user_group) }
  let(:blogger_user_group) { FactoryGirl.create(:blogger_user_group) }
  let(:site_admin_user_group) { FactoryGirl.create(:site_admin_user_group) }
  let(:corporate_customer_user_group) { FactoryGirl.create(:corporate_customer_user_group) }
  let(:complimentary_user_group) { FactoryGirl.create(:complimentary_user_group) }
  let(:marketing_manager_user_group) { FactoryGirl.create(:marketing_manager_user_group) }
  let(:customer_support_user_group) { FactoryGirl.create(:customer_support_user_group) }

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
  let(:comp_user) { FactoryGirl.create(:comp_user,
                                user_group_id: complimentary_user_group.id) }
  let(:customer_support_manager_user) { FactoryGirl.create(:customer_support_manager_user,
                                user_group_id: customer_support_user_group.id) }
  let(:marketing_manager_user) { FactoryGirl.create(:marketing_manager_user,
                                user_group_id: marketing_manager_user_group.id) }
  let(:admin_user) { FactoryGirl.create(:admin_user,
                                        user_group_id: site_admin_user_group.id) }

  let(:user_list) {[individual_student_user, admin_user, tutor_user, content_manager_user, blogger_user, corporate_customer_user, corporate_student_user, comp_user, customer_support_manager_user, marketing_manager_user] }

end
