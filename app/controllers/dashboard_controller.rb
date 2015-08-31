class DashboardController < ApplicationController

  def index
    seo_title_maker('Dashboard - Personalised to you', 'Your progress through all courses will be recorded here.', false)
    @dashboard_type = []
    if current_user.nil? || current_user.individual_student? || current_user.admin?
      @dashboard_type << 'individual_student'
    end
    @dashboard_type << 'admin' if current_user.try(:admin?)
    @dashboard_type << 'tutor' if current_user.try(:tutor?)
    @dashboard_type << 'content_manager' if current_user.try(:content_manager?)
    @dashboard_type << 'corporate_student' if current_user.try(:corporate_student?)
    @dashboard_type << 'corporate_customer' if current_user.try(:corporate_customer?)

    exam_levels = ExamLevel.all_active.all_live.all_in_order.all_without_exam_sections_enabled
    exam_sections = ExamSection.all_active.all_live.all_in_order
    if exam_sections
      @exam_sections = exam_sections
    else
      @exam_sections = ExamSection.all_active.all_in_order
    end
    @student_exam_tracks = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).with_active_cmes.all_in_order
    @latest_set = @student_exam_tracks.first
    @completed_student_exam_tracks = @student_exam_tracks.where(percentage_complete: 100)
    @incomplete_student_exam_tracks = @student_exam_tracks.where('percentage_complete < ?', 100)
    @latest_level_or_section = @latest_set.try(:course_module).try(:parent)

    incomplete_level_set_ids = @incomplete_student_exam_tracks.all.map(&:exam_level_id)
    incomplete_section_set_ids = @incomplete_student_exam_tracks.all.map(&:exam_section_id)
    completed_level_set_ids = @completed_student_exam_tracks.all.map(&:exam_level_id)
    completed_sections_set_ids = @completed_student_exam_tracks.all.map(&:exam_section_id)

    incomplete_levels = exam_levels.where(id: incomplete_level_set_ids)
    incomplete_sections = exam_sections.where(id: incomplete_section_set_ids)
    completed_levels = exam_levels.where(id: completed_level_set_ids)
    completed_sections = exam_sections.where(id: completed_sections_set_ids)
    @incomplete_courses = incomplete_levels + incomplete_sections
    @completed_courses = completed_levels + completed_sections
    @compulsory_courses = []

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

    if @dashboard_type.include?('corporate_student')

    end

    if @dashboard_type.include?('corporate_customer')

    end

    if @dashboard_type.include?('individual_student')

    end

    if @dashboard_type.include?('content_manager')

    end

    if @dashboard_type.include?('tutor')
      @tutor_exam_levels = ExamLevel.all_without_exam_sections_enabled.all_in_order.all_active.where(tutor_id: current_user.id)
      @tutor_exam_sections = ExamSection.all_in_order.all_active.where(tutor_id: current_user.id)
      @tutor_courses = @tutor_exam_levels + @tutor_exam_sections
      @level_course_modules = CourseModule.where(tutor_id: current_user.id).where(exam_level_id: @tutor_exam_levels)
      @section_course_modules = CourseModule.where(tutor_id: current_user.id).where(exam_section_id: @tutor_exam_sections)
      @cmeuls = CourseModuleElementUserLog.where(course_module_id: @course_modules)
      @monthly_cmeuls = CourseModuleElementUserLog.this_month.where(course_module_id: @course_modules)
      @total_seconds = @cmeuls.sum(:seconds_watched)
      @monthly_total_seconds = @monthly_cmeuls.sum(:seconds_watched)
    end

    if current_user && current_user.corporate_student?
      @exam_sections = @exam_sections.where('id not in (?)', current_user.restricted_exam_section_ids) unless current_user.restricted_exam_section_ids.empty?
      @compulsory_courses = ExamLevel.all_active.all_live.all_in_order.all_without_exam_sections_enabled.where(id: current_user.compulsory_exam_section_ids) +
                            ExamSection.all_active.all_live.all_in_order.where(id: current_user.compulsory_exam_section_ids)
    end
  end

end
