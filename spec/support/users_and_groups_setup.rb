require 'rails_helper'

shared_context 'users_and_groups_setup' do


  # User Groups
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let(:complimentary_user_group) { FactoryBot.create(:complimentary_user_group) }
  let(:tutor_user_group) { FactoryBot.create(:tutor_user_group) }
  let(:system_requirements_user_group) { FactoryBot.create(:system_requirements_user_group) }
  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:stripe_management_user_group) { FactoryBot.create(:stripe_management_user_group) }
  let(:user_management_user_group) { FactoryBot.create(:user_management_user_group) }
  let(:developers_user_group) { FactoryBot.create(:developers_user_group) }
  let(:marketing_manager_user_group) { FactoryBot.create(:marketing_manager_user_group) }
  let(:user_group_manager_user_group) { FactoryBot.create(:user_group_manager_user_group) }
  let(:admin_user_group) { FactoryBot.create(:admin_user_group) }
  let(:blocked_user_group) { FactoryBot.create(:blocked_user_group) }



  # Users
  let!(:basic_student) { FactoryBot.create(:basic_student, user_group_id: student_user_group.id) }

  let(:inactive_student_user) { FactoryBot.create(:inactive_student_user , user_group_id: student_user_group.id) }
  let(:unverified_student_user) { FactoryBot.create(:unverified_user, user_group_id: student_user_group.id) }


  ## Comp Student Users
  let(:comp_user) { FactoryBot.create(:comp_user, user_group_id: complimentary_user_group.id) }

  let(:unverified_comp_user) { FactoryBot.create(:unverified_comp_user,
                                                 user_group_id: complimentary_user_group.id) }

  ## Non-student Users
  let(:tutor_user) { FactoryBot.create(:tutor_user, user_group_id: tutor_user_group.id) }

  let(:system_requirements_user) { FactoryBot.create(:system_requirements_user,
                                                     user_group_id: system_requirements_user_group.id) }

  let(:content_management_user) { FactoryBot.create(:content_management_user,
                                                    user_group_id: content_management_user_group.id) }

  let(:stripe_management_user) { FactoryBot.create(:stripe_management_user,
                                                   user_group_id: stripe_management_user_group.id) }

  let(:user_management_user) { FactoryBot.create(:user_management_user,
                                                 user_group_id: user_management_user_group.id) }

  let(:developers_user) { FactoryBot.create(:developers_user, user_group_id: developers_user_group.id) }

  let(:marketing_manager_user) { FactoryBot.create(:marketing_manager_user,
                                                   user_group_id: marketing_manager_user_group.id) }

  let(:user_group_manager_user) { FactoryBot.create(:user_group_manager_user,
                                                    user_group_id: user_group_manager_user_group.id) }

  let(:admin_user) { FactoryBot.create(:admin_user, user_group_id: admin_user_group.id) }

  let(:blocked_user) { FactoryBot.create(:blocked_user, user_group_id: blocked_user_group.id) }


  let(:user_list) {[basic_student, inactive_student_user, unverified_student_user,
                    valid_subscription_student, invalid_subscription_student, comp_user, unverified_comp_user,
                    tutor_user, system_requirements_user, content_management_user, stripe_management_user,
                    user_management_user, developers_user, marketing_manager_user, user_group_manager_user, admin_user] }


end
