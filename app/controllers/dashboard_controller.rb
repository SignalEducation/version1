class DashboardController < ApplicationController

  def index
    seo_title_maker('personalised to you')
    @dashboard_type = []
    if current_user.nil? || current_user.individual_student?
      @dashboard_type << 'individual_student'
    end
    @dashboard_type << 'tutor' if current_user.try(:tutor?)
    @dashboard_type << 'admin' if current_user.try(:admin?)

    # @dashboard_type could == ['blogger','tutor','admin']
    if @dashboard_type.include?('individual_student')
      # create the stuff an individual student should see


    end
    if @dashboard_type.include?('tutor')
      # create the stuff a tutor would see
    end
    if @dashboard_type.include?('admin')
      # create the stuff an admin would see
    end
  end

end
