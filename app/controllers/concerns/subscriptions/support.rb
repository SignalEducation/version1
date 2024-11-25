# frozen_string_literal: true

module Subscriptions
  module Support
    extend ActiveSupport::Concern

    # redirect if exam_body doesn't exists and user doesn't have a preferred exam body saved.
    # or
    # redirect user already have a active subscription.
    # or
    # redirect to root if current user is not a standard student user
    def redirects_conditions
      exam_body_check ||
        active_subscriptions_check ||
        standard_student? ||
        return
    end

    def filtered_plan
      filters = %w[prioritise_plan_frequency subscription_plan_id plan_guid]

      # return a default plan if filters are empty in params
      return default_plan if (params.keys & filters).empty?

      @plans.filter_from_params(params.slice(:prioritise_plan_frequency, :subscription_plan_id, :plan_guid)).first
    end

    private

    def exam_body_check
      exam_body_check           = ExamBody.exists?(params[:exam_body_id].to_i)
      preferred_exam_body_check = current_user.preferred_exam_body.present?

      return if exam_body_check || preferred_exam_body_check

      redirect_to(edit_preferred_exam_body_path) and return
    end

    def active_subscriptions_check
      exam_body_id = params[:exam_body_id] || current_user.preferred_exam_body&.id
      active_subscriptions =
        current_user.active_subscriptions_for_exam_body(exam_body_id)
      return if active_subscriptions.blank?

      url = redirect_url(active_subscriptions)

      redirect_to(url) and return
    end

    def redirect_url(active_subscriptions)
      states = (active_subscriptions.map(&:state) & %w[active pending_cancellation])
      states.any? ? new_subscription_plan_changes_url(active_subscriptions.first) : account_url
    end

    def standard_student?
      return if current_user.standard_student_user?

      redirect_to(root_url) and return
    end

    def default_plan
      if @plans.yearly.any?
        @plans.find_by(payment_frequency_in_months: 12)
      else
        @plans.first
      end
    end
  end
end
