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
      @course_modules = CourseModule.where(tutor_id: current_user.id)
    end

    if @dashboard_type.include?('admin')
      @all_users = User.all
      @active_users = @all_users.where(active: true)
      @new_users = @all_users.where('created_at > ?', Time.now - 7.days)
      @all_user_groups = UserGroup.all
      @new_user_groups = @all_user_groups.where('created_at > ?', Time.now - 7.days)
      @all_subject_areas = SubjectArea.all
      @active_subject_areas = @all_subject_areas.where(active: true)
      @new_subject_areas = @all_subject_areas.where('created_at > ?', Time.now - 7.days)
      @all_institutions = Institution.all
      @active_institutions = @all_institutions.where(active: true)
      @new_institutions = @all_institutions.where('created_at > ?', Time.now - 7.days)
      @all_qualifications = Qualification.all
      @active_qualifications = @all_qualifications.where(active: true)
      @new_qualifications = @all_qualifications.where('created_at > ?', Time.now - 7.days)
      @all_exam_levels = ExamLevel.all
      @active_exam_levels = @all_exam_levels.where(active: true)
      @new_exam_levels = @all_exam_levels.where('created_at > ?', Time.now - 7.days)
    end

  end

end
