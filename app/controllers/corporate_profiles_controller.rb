class CorporateProfilesController < ApplicationController

  before_action :logged_out_required
  before_action :get_variables

  def show
    @corporate_student = User.new
  end

  def new

  end

  def create

  end


  protected

  def get_variables
    @corporate_customer = CorporateCustomer.where(subdomain: request.subdomain).first
  end

  def allowed_params
    usr_params = [:first_name, :last_name, :email, :employee_guid]
    params.require(:corporate_student).permit(usr_params)
  end

end
