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
  let!(:student_user) { FactoryBot.create(:student_user, user_group_id: student_user_group.id) }
  let!(:student_access) { FactoryBot.create(:trial_student_access, user_id: student_user.id) }

  let(:inactive_student_user) { FactoryBot.create(:inactive_student_user , user_group_id: student_user_group.id) }
  let(:unverified_student_user) { FactoryBot.create(:unverified_user, user_group_id: student_user_group.id) }

  ## Trial Student Users
  let!(:valid_trial_student) { FactoryBot.create(:valid_free_trial_student,
                                                 user_group_id: student_user_group.id) }
  let!(:valid_trial_student_access) { FactoryBot.create(:valid_free_trial_student_access,
                                                        user_id: valid_trial_student.id) }
  let!(:invalid_trial_student) { FactoryBot.create(:invalid_free_trial_student,
                                                 user_group_id: student_user_group.id) }
  let!(:invalid_trial_student_access) { FactoryBot.create(:invalid_free_trial_student_access,
                                                        user_id: invalid_trial_student.id) }


  ## Sub Student Users
  let!(:valid_subscription_student) { FactoryBot.create(:valid_subscription_student,
                                                 user_group_id: student_user_group.id) }
  let!(:valid_subscription_student_access) { FactoryBot.create(:trial_student_access,
                                                          user_id: valid_subscription_student.id) }

  let!(:valid_subscription) { FactoryBot.create(:valid_subscription, user_id: valid_subscription_student.id,
                                                stripe_customer_id: valid_subscription_student.stripe_customer_id ) }




  let!(:invalid_subscription_student) { FactoryBot.create(:invalid_subscription_student,
                                                 user_group_id: student_user_group.id) }
  let!(:invalid_subscription_student_access) { FactoryBot.create(:trial_student_access,
                                                          user_id: invalid_subscription_student.id) }

  let!(:invalid_subscription) { FactoryBot.create(:invalid_subscription,
                                                  user_id: invalid_subscription_student.id,
                                                  stripe_customer_id: invalid_subscription_student.stripe_customer_id )}



  ## Comp Student Users
  let(:comp_user) { FactoryBot.create(:comp_user, user_group_id: complimentary_user_group.id) }
  let!(:comp_student_access) { FactoryBot.create(:complimentary_student_access, user_id: comp_user.id) }

  let(:unverified_comp_user) { FactoryBot.create(:unverified_comp_user,
                                                 user_group_id: complimentary_user_group.id) }
  let!(:unverified_comp_student_access) { FactoryBot.create(:complimentary_student_access,
                                                            user_id: unverified_comp_user.id) }

  ## Non-student Users
  let(:tutor_user) { FactoryBot.create(:tutor_user, user_group_id: tutor_user_group.id) }
  let!(:tutor_student_access) { FactoryBot.create(:complimentary_student_access, user_id: tutor_user.id) }

  let(:system_requirements_user) { FactoryBot.create(:system_requirements_user,
                                                     user_group_id: system_requirements_user_group.id) }
  let!(:system_requirements_student_access) { FactoryBot.create(:complimentary_student_access,
                                                                user_id: system_requirements_user.id) }

  let(:content_management_user) { FactoryBot.create(:content_management_user,
                                                    user_group_id: content_management_user_group.id) }
  let!(:content_management_user_student_access) { FactoryBot.create(:complimentary_student_access,
                                                                    user_id: content_management_user.id) }

  let(:stripe_management_user) { FactoryBot.create(:stripe_management_user,
                                                   user_group_id: stripe_management_user_group.id) }
  let!(:stripe_management_student_access) { FactoryBot.create(:complimentary_student_access,
                                                              user_id: stripe_management_user.id) }

  let(:user_management_user) { FactoryBot.create(:user_management_user,
                                                 user_group_id: user_management_user_group.id) }
  let!(:user_management_student_access) { FactoryBot.create(:complimentary_student_access,
                                                            user_id: user_management_user.id) }

  let(:developers_user) { FactoryBot.create(:developers_user, user_group_id: developers_user_group.id) }
  let!(:developers_student_access) { FactoryBot.create(:complimentary_student_access,
                                                       user_id: developers_user.id) }

  let(:marketing_manager_user) { FactoryBot.create(:marketing_manager_user,
                                                   user_group_id: marketing_manager_user_group.id) }
  let!(:marketing_manager_student_access) { FactoryBot.create(:complimentary_student_access,
                                                              user_id: marketing_manager_user.id) }

  let(:user_group_manager_user) { FactoryBot.create(:user_group_manager_user,
                                                    user_group_id: user_group_manager_user_group.id) }
  let!(:user_group_manager_student_access) { FactoryBot.create(:complimentary_student_access,
                                                               user_id: user_group_manager_user.id) }

  let(:admin_user) { FactoryBot.create(:admin_user, user_group_id: admin_user_group.id) }
  let!(:admin_student_access) { FactoryBot.create(:complimentary_student_access,
                                                  user_id: admin_user.id) }

  let(:blocked_user) { FactoryBot.create(:blocked_user, user_group_id: blocked_user_group.id) }
  let!(:blocked_user_student_access) { FactoryBot.create(:complimentary_student_access,
                                                         user_id: blocked_user.id) }



  let(:user_list) {[valid_trial_student, invalid_trial_student, valid_subscription_student,
                    invalid_subscription_student, comp_user, tutor_user, system_requirements_user,
                    content_management_user, stripe_management_user, user_management_user, developers_user,
                    marketing_manager_user, user_group_manager_user, admin_user, blocked_user] }


end
