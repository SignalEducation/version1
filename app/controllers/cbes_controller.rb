# frozen_string_literal: true

class CbesController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access student_user])
  end
  before_action :cbe_access?

  def show
    @cbe = Cbe.find(params[:id])
  end

  private

  def cbe_access?
    return if current_user.purchased_cbe?(params[:id])

    flash[:error] = 'You need to purchase it before access.'
    redirect_to prep_products_url
  end
end
