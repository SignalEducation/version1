# frozen_string_literal: true

class CbesController < ApplicationController
  before_action :logged_in_required
  before_action :cbe_access?
  before_action :exercise_access?

  def show
    @exercise_id          = params[:exercise_id]
    @introduction_page_id = Cbe::IntroductionPage.select(:id).where(cbe_id: params[:id]).order(:sorting_order).first.id
  end

  private

  def cbe_access?
    return if current_user.purchased_cbe?(params[:id]) || current_user.non_student_user?
    return if current_user.exercise_ids.include?(params[:exercise_id].to_i)

    flash[:error] = 'You need to purchase it before access.'
    redirect_to prep_products_url
  end

  def exercise_access?
    return if current_user.non_student_user?
    return if %w[pending returned].include?(Exercise.find(params[:exercise_id]).state)

    flash[:error] = 'You do not have access to this CBE.'
    redirect_to prep_products_url
  end
end
