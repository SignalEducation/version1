# frozen_string_literal: true

class CbesController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access student_user])
  end
  before_action :cbe_access?
  before_action :exercise_access?

  def show
    @cbe         = Cbe.find(params[:id])
    @exercise_id = params[:exercise_id]
  end

  private

  def cbe_access?
    return if current_user.purchased_cbe?(params[:id]) || current_user.non_student_user?

    flash[:error] = 'You need to purchase it before access.'
    redirect_to prep_products_url
  end

  def exercise_access?
    return if Exercise.find(params[:exercise_id]).pending?

    flash[:error] = 'You have not access to this CBE.'
    redirect_to prep_products_url
  end
end
