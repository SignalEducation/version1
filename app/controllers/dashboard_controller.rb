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
      @student_exam_tracks = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).order(updated_at: :desc)
    end

    if @dashboard_type.include?('tutor')
      # create the stuff a tutor would see
      @course_modules = CourseModule.where(tutor_id: current_user.id)
    end

    if @dashboard_type.include?('admin')
      # create the stuff an admin would see
      @all_users = User.all
      #@new_users = @all_users.where(created_at > (Date.today - 7))
      @all_user_groups = UserGroup.all
      @all_subject_areas = SubjectArea.all
      @all_institutions = Institution.all
      @all_qualifications = Qualification.all
      @all_exam_levels = ExamLevel.all
    end

  end

end
