class VisitsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables, except: [:all_index, :all_show]

  def index
    @visits = @user.visits.all
  end

  def all_index
    @visits = Visit.all
  end

  def show
    @visit = Visit.find(params[:id])
  end

  def all_show
    @visit = Visit.find(params[:id])
  end

  protected

  def get_variables
    @user = User.find(params[:user_id])
    seo_title_maker('User Visits', nil, false)
  end

end
