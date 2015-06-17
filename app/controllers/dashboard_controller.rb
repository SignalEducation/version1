class DashboardController < ApplicationController

  def index
    seo_title_maker('Dashboard - Personalised to you', "Track your progress as you study using LearnSignal's personalised dashboard", false)
    @dashboard_type = []
    if current_user.nil? || current_user.individual_student? || current_user.admin?
      @dashboard_type << 'individual_student'
    end
    @dashboard_type << 'admin' if current_user.try(:admin?)
    @dashboard_type << 'tutor' if current_user.try(:tutor?)
    @dashboard_type << 'content_manager' if current_user.try(:content_manager?)

    # @dashboard_type could == ['blogger','tutor','admin']
    if @dashboard_type.include?('individual_student')
      @student_exam_tracks = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).with_active_cmes.all_in_order
      @latest_set = @student_exam_tracks.first
      @completed_student_exam_tracks = @student_exam_tracks.where(percentage_complete: 100)
      @incomplete_student_exam_tracks = @student_exam_tracks.where('percentage_complete < ?', 100)
      @latest_level_or_section = @latest_set.try(:course_module).try(:parent)

    end

    if @dashboard_type.include?('tutor')
      @exam_levels = ExamLevel.all_in_order.all_active.where(tutor_id: current_user.id)
      @course_modules = CourseModule.where(tutor_id: current_user.id).where(exam_level_id: @exam_levels)
      @cmeuls = CourseModuleElementUserLog.where(course_module_id: @course_modules)
      @monthly_cmeuls = CourseModuleElementUserLog.this_month.where(course_module_id: @course_modules)
      @total_seconds = @cmeuls.sum(:seconds_watched)
      @monthly_total_seconds = @monthly_cmeuls.sum(:seconds_watched)
    end

    if @dashboard_type.include?('content_manager')
      @exam_levels = ExamLevel.all_in_order
      @course_modules = CourseModule.all_in_order.where(exam_level_id: @exam_levels)
    end

    if @dashboard_type.include?('admin')
      @all_users = User.all
      @qualifications = Qualification.all
      @new_users = @all_users.where('created_at > ?', Proc.new{Time.now - 7.days}.call)
      @exam_levels = ExamLevel.all_in_order
      @course_modules = CourseModule.all_in_order.where(exam_level_id: @exam_levels)
      @cmeuls = CourseModuleElementUserLog.where(course_module_id: @course_modules)
      @monthly_cmeuls = CourseModuleElementUserLog.this_month.where(course_module_id: @course_modules)
      @total_seconds = @cmeuls.sum(:seconds_watched)
      @monthly_total_seconds = @monthly_cmeuls.sum(:seconds_watched)
    end

  end

end
