# frozen_string_literal: true

class VisitsController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[user_management_access]) }
  before_action :management_layout
  before_action :set_seo, :get_user

  def index
    @visits = @user.ahoy_visits.all_in_order.paginate(per_page: 50, page: params[:page])
  end

  def show
    @visit = Ahoy::Visit.find(params[:id])
  end

  protected

  def get_user
    @user = User.find(params[:user_id])
  end

  def set_seo
    seo_title_maker('User Visits', nil, false)
  end
end
