class ManagementConsolesController < ApplicationController

  before_action :logged_in_required
  before_action except: [:system_requirements] do
    ensure_user_has_access_rights(%w(non_student_user))
  end
  before_action only: [:system_requirements] do
    ensure_user_has_access_rights(%w(marketing_resources_access system_requirements_access))
  end
  before_action :get_variables


  def index

  end

  def system_requirements
    @home_pages = HomePage.paginate(per_page: 10, page: params[:page]).all_in_order
  end

  def public_resources
    @faq_sections = FaqSection.paginate(per_page: 50, page: params[:page]).all_in_order
  end



  protected

  def get_variables
    @layout = 'management'
  end

end