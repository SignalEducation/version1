class ManagementConsolesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables


  def index
    #Default view for all management users. General stats on site - user number, sub numbers, enrollment numbers, course numbers
  end

  def system_requirements
    @home_pages = HomePage.paginate(per_page: 10, page: params[:page]).all_in_order

  end



  protected

  def get_variables
    @navbar = false
    @footer = false
    @top_margin = false
  end

end