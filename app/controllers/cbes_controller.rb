# frozen_string_literal: true

class CbesController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access student_user])
  end
  before_action :cbe_access?
  before_action :cbe_layout

  def show; end

  private

  def cbe_access?
    return if current_user.purchased_cbe?(params[:id])

    flash[:error] = 'You need to purchase it before access.'
    # todo(Giordano), maybe redirect user to product page.
  end
end
