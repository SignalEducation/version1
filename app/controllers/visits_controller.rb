# frozen_string_literal: true

class VisitsController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[user_management_access]) }
  before_action :management_layout
  before_action :set_seo

  def index
    @user = User.find(params[:user_id])
    @visits = @user.visits.all.paginate(per_page: 50, page: params[:page])
  end

  def all_index
    @visits =
      if params[:search_term].to_s.blank?
        Visit.order(started_at: :desc).paginate(per_page: 50, page: params[:page])
      else
        Visit.search_for(params[:search_term].to_s).paginate(per_page: 50, page: params[:page])
      end
  end

  def show
    @user  = User.find(params[:user_id])
    @visit = Visit.find(params[:id])
  end

  def all_show
    @visit = Visit.find(params[:id])
  end

  protected

  def set_seo
    seo_title_maker('User Visits', nil, false)
  end
end
