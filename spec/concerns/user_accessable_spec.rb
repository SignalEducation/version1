# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'user_accessable' do
  let(:user) { create(:user) }

  describe '#student_user?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.student_user?).to be_falsey
    end

    it 'returns TRUE for a student_user user_group' do
      user = build_stubbed(:student_user)

      expect(user.student_user?).to be_truthy
    end

    it 'returns FALSE for a non student_user user_group' do
      user = build_stubbed(:tutor_user)

      expect(user.student_user?).to be_falsey
    end
  end

  describe '#non_student_user?' do
    it 'returns TRUE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.non_student_user?).to be_truthy
    end

    it 'returns TRUE for a non_student_user user_group' do
      user = build_stubbed(:tutor_user)

      expect(user.non_student_user?).to be_truthy
    end

    it 'returns FALSE for a student_user user_group' do
      user = build_stubbed(:student_user)

      expect(user.non_student_user?).to be_falsey
    end
  end

  describe '#standard_student_user?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.standard_student_user?).to be_falsey
    end

    it 'returns FALSE for a non student_user' do
      user = build_stubbed(:tutor_user)

      expect(user.standard_student_user?).to be_falsey
    end

    it 'returns FALSE for a student_user if the user_group does not have trial_or_sub_required' do
      group = build_stubbed(:student_user_group, trial_or_sub_required: false)
      user = build_stubbed(:user, user_group: group)

      expect(user.standard_student_user?).to be_falsey
    end

    it 'returns TRUE for a student_user if the user_group has trial_or_sub_required' do
      group = build_stubbed(:student_user_group, trial_or_sub_required: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.standard_student_user?).to be_truthy
    end
  end

  describe '#complimentary_user?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.complimentary_user?).to be_falsey
    end

    it 'returns FALSE for a non student_user' do
      user = build_stubbed(:tutor_user)

      expect(user.complimentary_user?).to be_falsey
    end

    it 'returns TRUE for a student_user if the user_group does not have trial_or_sub_required' do
      group = build_stubbed(:student_user_group, trial_or_sub_required: false)
      user = build_stubbed(:user, user_group: group)

      expect(user.complimentary_user?).to be_truthy
    end

    it 'returns FALSE for a student_user if the user_group has trial_or_sub_required' do
      group = build_stubbed(:student_user_group, trial_or_sub_required: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.complimentary_user?).to be_falsey
    end
  end

  describe '#non_verified_user?' do
    it 'returns TRUE if email_verified is FALSE and an email_verification_code exists' do
      user = build_stubbed(:user, email_verified: false, email_verification_code: 'code')

      expect(user.non_verified_user?).to be_truthy
    end

    it 'returns FALSE if email_verified is TRUE' do
      user = build_stubbed(:user, email_verified: true)

      expect(user.non_verified_user?).to be_falsey
    end

    it 'returns FALSE if there is no email_verification_code' do
      user = build_stubbed(:user, email_verified: true, email_verification_code: nil)

      expect(user.non_verified_user?).to be_falsey
    end
  end

  describe '#blocked_user?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.blocked_user?).to be_falsey
    end

    it 'returns TRUE if the blocked_user value for the user_group is true' do
      group = build_stubbed(:user_group, blocked_user: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.blocked_user?).to be_truthy
    end

    it 'returns FALSE if the blocked_user value for the user_group is FALSE' do
      group = build_stubbed(:user_group, blocked_user: false)
      user = build_stubbed(:user, user_group: group)

      expect(user.blocked_user?).to be_falsey
    end
  end

  describe '#system_requirements_access?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.system_requirements_access?).to be_falsey
    end

    it 'returns TRUE for a system_requirements_access user_group' do
      group = build_stubbed(:user_group, system_requirements_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.system_requirements_access?).to be_truthy
    end

    it 'returns FALSE for a non system_requirements_access user_group' do
      user = build_stubbed(:student_user)

      expect(user.system_requirements_access?).to be_falsey
    end
  end

  describe '#tutor_user?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.tutor_user?).to be_falsey
    end

    it 'returns TRUE for a tutor user_group' do
      group = build_stubbed(:user_group, tutor: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.tutor_user?).to be_truthy
    end

    it 'returns FALSE for a non tutor user_group' do
      user = build_stubbed(:student_user)

      expect(user.tutor_user?).to be_falsey
    end
  end

  describe '#content_management_access?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.content_management_access?).to be_falsey
    end

    it 'returns TRUE for a content_management_access user_group' do
      group = build_stubbed(:user_group, content_management_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.content_management_access?).to be_truthy
    end

    it 'returns FALSE for a non content_management_access user_group' do
      user = build_stubbed(:student_user)

      expect(user.content_management_access?).to be_falsey
    end
  end

  describe '#exercise_corrections_access?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.exercise_corrections_access?).to be_falsey
    end

    it 'returns TRUE for a exercise_corrections_access user_group' do
      group = build_stubbed(:user_group, exercise_corrections_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.exercise_corrections_access?).to be_truthy
    end

    it 'returns FALSE for a non exercise_corrections_access user_group' do
      user = build_stubbed(:student_user)

      expect(user.exercise_corrections_access?).to be_falsey
    end
  end

  describe '#stripe_management_access?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.stripe_management_access?).to be_falsey
    end

    it 'returns TRUE for a stripe_management_access user_group' do
      group = build_stubbed(:user_group, stripe_management_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.stripe_management_access?).to be_truthy
    end

    it 'returns FALSE for a non stripe_management_access user_group' do
      user = build_stubbed(:student_user)

      expect(user.stripe_management_access?).to be_falsey
    end
  end

  describe '#user_management_access?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.user_management_access?).to be_falsey
    end

    it 'returns TRUE for a user_management_access user_group' do
      group = build_stubbed(:user_group, user_management_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.user_management_access?).to be_truthy
    end

    it 'returns FALSE for a non user_management_access user_group' do
      user = build_stubbed(:student_user)

      expect(user.user_management_access?).to be_falsey
    end
  end

  describe '#developer_access?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.developer_access?).to be_falsey
    end

    it 'returns TRUE for a developer_access user_group' do
      group = build_stubbed(:user_group, developer_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.developer_access?).to be_truthy
    end

    it 'returns FALSE for a non developer_access user_group' do
      user = build_stubbed(:student_user)

      expect(user.developer_access?).to be_falsey
    end
  end

  describe '#marketing_resources_access?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.marketing_resources_access?).to be_falsey
    end

    it 'returns TRUE for a marketing_resources_access user_group' do
      group = build_stubbed(:user_group, marketing_resources_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.marketing_resources_access?).to be_truthy
    end

    it 'returns FALSE for a non marketing_resources_access user_group' do
      user = build_stubbed(:student_user)

      expect(user.marketing_resources_access?).to be_falsey
    end
  end

  describe '#user_group_management_access?' do
    it 'returns FALSE if there is no user_group' do
      user = build_stubbed(:user, user_group: nil)

      expect(user.user_group_management_access?).to be_falsey
    end

    it 'returns TRUE for a user_group_management_access user_group' do
      group = build_stubbed(:user_group, user_group_management_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.user_group_management_access?).to be_truthy
    end

    it 'returns FALSE for a non user_group_management_access user_group' do
      user = build_stubbed(:student_user)

      expect(user.user_group_management_access?).to be_falsey
    end
  end

  # def admin?
  #   user_group_management_access? && developer_access? && system_requirements_access?
  # end

  describe '#admin?' do
    it 'returns TRUE if the user is in the three correct groups' do
      group = build_stubbed(:user_group, user_group_management_access: true, developer_access: true, system_requirements_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.admin?).to be_truthy
    end

    it 'returns FALSE if the user is not user_group_management_access' do
      group = build_stubbed(:user_group, user_group_management_access: false, developer_access: true, system_requirements_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.admin?).to be_falsey
    end

    it 'returns FALSE if the user is not developer_access' do
      group = build_stubbed(:user_group, user_group_management_access: true, developer_access: false, system_requirements_access: true)
      user = build_stubbed(:user, user_group: group)

      expect(user.admin?).to be_falsey
    end

    it 'returns FALSE if the user is not system_requirements_access' do
      group = build_stubbed(:user_group, user_group_management_access: true, developer_access: true, system_requirements_access: false)
      user = build_stubbed(:user, user_group: group)

      expect(user.admin?).to be_falsey
    end
  end

  describe '#referred_user?' do
    it 'returns TRUE for student users with referred_signup' do
      referred_signup = build_stubbed(:referred_signup)
      user = build_stubbed(:student_user, referred_signup: referred_signup)

      expect(user.referred_user?).to be_truthy
    end

    it 'returns FALSE for a non-student_user' do
      referred_signup = build_stubbed(:referred_signup)
      user = build_stubbed(:tutor_user, referred_signup: referred_signup)

      expect(user.referred_user?).to be_falsey
    end

    it 'returns FALSE for a student_user without referred_signup' do
      user = build_stubbed(:student_user, referred_signup: nil)

      expect(user.referred_user?).to be_falsey
    end
  end
end
