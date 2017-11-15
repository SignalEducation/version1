class ManagementConsolesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables


  def index
    #Default view for all management users. General stats on site - user number, sub numbers, enrollment numbers, course numbers
  end



  protected

  def get_variables
  end

end