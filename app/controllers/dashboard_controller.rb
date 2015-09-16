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

    @courses = SubjectCourse.all_active.all_live.all_in_order
    @student_exam_tracks = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).with_active_cmes.all_in_order
    @latest_set = @student_exam_tracks.first
    @completed_student_exam_tracks = @student_exam_tracks.where(percentage_complete: 100)
    @incomplete_student_exam_tracks = @student_exam_tracks.where('percentage_complete < ?', 100)
    @latest_course = @latest_set.try(:course_module).try(:parent)

    incomplete_set_ids = @incomplete_student_exam_tracks.all.map(&:subject_course_id)
    completed_set_ids = @completed_student_exam_tracks.all.map(&:subject_course_id)

    @incomplete_courses = @courses.where(id: incomplete_set_ids)
    @completed_courses = @courses.where(id: completed_set_ids)
    @compulsory_courses = []

    if @dashboard_type.include?('admin')
      @all_users = User.all
      @new_users = @all_users.where('created_at > ?', Proc.new{Time.now - 7.days}.call)
      @all_courses = SubjectCourse.all_in_order
      @course_modules = CourseModule.all_in_order.where(subject_course_id: @all_courses)
      @cmeuls = CourseModuleElementUserLog.where(course_module_id: @course_modules)
      @monthly_cmeuls = CourseModuleElementUserLog.this_month.where(course_module_id: @course_modules)
      @total_seconds = @cmeuls.sum(:seconds_watched)
      @monthly_total_seconds = @monthly_cmeuls.sum(:seconds_watched)
    end

    if @dashboard_type.include?('corporate_student')
      if current_user && current_user.corporate_student?
        @exam_sections = @exam_sections.where('id not in (?)', current_user.restricted_exam_section_ids) unless current_user.restricted_exam_section_ids.empty?
        compulsory_levels = ExamLevel.all_active.all_live.all_without_exam_sections_enabled.where(id: current_user.compulsory_exam_level_ids).all_in_order
        compulsory_sections = ExamSection.all_active.all_live.where(id: current_user.compulsory_exam_section_ids).all_in_order
        @compulsory_courses = compulsory_levels + compulsory_sections
      end


    end

    if @dashboard_type.include?('corporate_customer')

    end

    if @dashboard_type.include?('individual_student')

    end

    if @dashboard_type.include?('content_manager')

    end

    if @dashboard_type.include?('tutor')
      @tutor_courses = SubjectCourse.all_in_order.all_active.where(tutor_id: current_user.id)
      @course_modules = CourseModule.where(tutor_id: current_user.id).where(subject_course_id: @tutor_courses)
      @cmeuls = CourseModuleElementUserLog.where(course_module_id: @course_modules)
      @monthly_cmeuls = CourseModuleElementUserLog.this_month.where(course_module_id: @course_modules)
      @total_seconds = @cmeuls.sum(:seconds_watched)
      @monthly_total_seconds = @monthly_cmeuls.sum(:seconds_watched)
    end

    if current_user && current_user.corporate_student?
      @exam_sections = @exam_sections.where('id not in (?)', current_user.restricted_exam_section_ids) unless current_user.restricted_exam_section_ids.empty?
      compulsory_levels = ExamLevel.all_active.all_live.all_without_exam_sections_enabled.where(id: current_user.compulsory_exam_level_ids).all_in_order
      compulsory_sections = ExamSection.all_active.all_live.where(id: current_user.compulsory_exam_section_ids).all_in_order
      @compulsory_courses = compulsory_levels + compulsory_sections
    end
  end

end
