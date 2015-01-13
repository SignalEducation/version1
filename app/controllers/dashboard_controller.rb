class DashboardController < ApplicationController

  def index
    seo_title_maker('personalised to you')
    @dashboard_type = []
    if current_user.nil? || current_user.individual_student? || current_user.admin?
      @dashboard_type << 'individual_student'
    end
    @dashboard_type << 'tutor' if current_user.try(:tutor?)
    @dashboard_type << 'admin' if current_user.try(:admin?)
    @dashboard_type << 'content_manager' if current_user.try(:content_manager?)

    # @dashboard_type could == ['blogger','tutor','admin']
    if @dashboard_type.include?('individual_student')
      # create the stuff an individual student should see
      @student_exam_tracks = StudentExamTrack.get_user_stuff(current_user.try(:id), current_session_guid).order(updated_at: :desc)

      @total_cmes = @student_exam_tracks.first.latest_course_module_element.course_module.course_module_elements.inspect
      #@completed_cmes = @student_exam_tracks.first.latest_course_module_element.course_module.course_module_elements.course_module_element_user_logs.where(element_completed: true)
      @cm_with_jumboquiz = @student_exam_tracks.first.latest_course_module_element.course_module.course_module_jumbo_quiz

      #if set.latest_course_module_element.course_module.course_module_jumbo_quiz

    end
    if @dashboard_type.include?('tutor')
      # create the stuff a tutor would see
    end
    if @dashboard_type.include?('admin')
      # create the stuff an admin would see
    end
  end

end
