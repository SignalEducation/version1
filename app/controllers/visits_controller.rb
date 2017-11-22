# == Schema Information
#
# Table name: visits
#
#  id               :uuid             not null, primary key
#  visitor_id       :uuid
#  ip               :string
#  user_agent       :text
#  referrer         :text
#  landing_page     :text
#  user_id          :integer
#  referring_domain :string
#  search_keyword   :string
#  browser          :string
#  os               :string
#  device_type      :string
#  screen_height    :integer
#  screen_width     :integer
#  country          :string
#  region           :string
#  city             :string
#  postal_code      :string
#  latitude         :decimal(, )
#  longitude        :decimal(, )
#  utm_source       :string
#  utm_medium       :string
#  utm_term         :string
#  utm_content      :string
#  utm_campaign     :string
#  started_at       :datetime
#

class VisitsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(user_management_access))
  end
  before_action :get_variables

  def index
    @user = User.find(params[:user_id])
    @visits = @user.visits.all.paginate(per_page: 50, page: params[:page])
  end

  def all_index
    @visits = params[:search_term].to_s.blank? ?
        @visits = Visit.paginate(per_page: 50, page: params[:page]) :
        @visits = Visit.search_for(params[:search_term].to_s).
            paginate(per_page: 50, page: params[:page])

  end

  def show
    @user = User.find(params[:user_id])
    @visit = Visit.find(params[:id])
  end

  def all_show
    @visit = Visit.find(params[:id])
  end

  protected

  def get_variables
    seo_title_maker('User Visits', nil, false)
    @layout = 'management'
  end

end
