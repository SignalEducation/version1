# frozen_string_literal: true

module UserAccessable
  extend ActiveSupport::Concern

  def student_user?
    user_group&.student_user
  end

  def non_student_user?
    !user_group&.student_user
  end

  def standard_student_user?
    student_user? && user_group&.trial_or_sub_required
  end

  def bank_transfer_user?
    user_group.name = 'bank_transfer_payments'
  end

  def lifetime_subscriber?(group_id)
    orders.includes(:product).with_state(:completed).
      where(products: { product_type: :lifetime_access }).
      where(products: { group_id: group_id }).any?
  end

  def course_access?(course_id)
    orders.includes(:product).with_state(:completed).
      where(products: { product_type: :course_access }).
      where(products: { course_id: course_id }).any?
  end

  def complimentary_user?
    user_group&.student_user && !user_group&.trial_or_sub_required
  end

  def non_verified_user?
    !email_verified && email_verification_code
  end

  def blocked_user?
    user_group&.blocked_user
  end

  def system_requirements_access?
    user_group&.system_requirements_access
  end

  def tutor_user?
    user_group&.tutor
  end

  def content_management_access?
    user_group&.content_management_access
  end

  def exercise_corrections_access?
    user_group&.exercise_corrections_access
  end

  def stripe_management_access?
    user_group&.stripe_management_access
  end

  def user_management_access?
    user_group&.user_management_access
  end

  def developer_access?
    user_group&.developer_access
  end

  def marketing_resources_access?
    user_group&.marketing_resources_access
  end

  def user_group_management_access?
    user_group&.user_group_management_access
  end

  def admin?
    user_group_management_access? && developer_access? && system_requirements_access?
  end

  def referred_user?
    student_user? && referred_signup
  end
end
