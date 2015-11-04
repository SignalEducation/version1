class DashboardController < ApplicationController

  before_action :logged_in_required

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

    logs = SubjectCourseUserLog.where(user_id: current_user.id)
    @active_logs = logs.where('percentage_complete < ?', 100)
    active_logs_ids = @active_logs.all.map(&:subject_course_id)
    @completed_logs = logs.where('percentage_complete > ?', 99)
    completed_logs_ids = @completed_logs.all.map(&:subject_course_id)
    @compulsory_logs = SubjectCourseUserLog.where(user_id: current_user.id)

    @incomplete_courses = @courses.where(id: active_logs_ids)
    @completed_courses = @courses.where(id: completed_logs_ids)
    @compulsory_courses = []

    if @dashboard_type.include?('admin')

    end

    if @dashboard_type.include?('corporate_student')
      if current_user && current_user.corporate_student?
        @subject_courses = @courses.where('id not in (?)', current_user.restricted_subject_course_ids) unless current_user.restricted_subject_course_ids.empty?
        @compulsory_courses = SubjectCourse.all_active.all_live.where(id: current_user.compulsory_subject_course_ids).all_in_order
      end


    end

    if @dashboard_type.include?('corporate_customer')

    end

    if @dashboard_type.include?('individual_student')

    end

    if @dashboard_type.include?('content_manager')

    end

    if @dashboard_type.include?('tutor')

      # Compile all CourseModuleElementUserLog for the current_user(tutor)
      @tutor_courses = SubjectCourse.all_in_order.all_active.where(tutor_id: current_user.id)
      @course_modules = CourseModule.where(tutor_id: current_user.id).where(subject_course_id: @tutor_courses)
      @quiz_logs = CourseModuleElementUserLog.where(is_quiz: true).where(course_module_id: @course_modules)
      @video_logs = CourseModuleElementUserLog.where(is_video: true).where(course_module_id: @course_modules)

      #Graph Dates Data
      date_to  = Date.parse("#{Proc.new{Time.now}.call}")
      date_from = date_to - 5.months
      date_range = date_from..date_to
      date_months = date_range.map {|d| Date.new(d.year, d.month, 1) }.uniq
      @labels = date_months.map {|d| d.strftime "%B" }

      #CourseModuleElementUserLogs Video Data
      @videos_this_month = @video_logs.this_month.count | 0
      @videos_one_month_ago = @video_logs.one_month_ago.count | 0
      @videos_two_months_ago = @video_logs.two_months_ago.count | 0
      @videos_three_months_ago = @video_logs.three_months_ago.count | 0
      @videos_four_months_ago = @video_logs.four_months_ago.count | 0
      @videos_five_months_ago = @video_logs.five_months_ago.count | 0

      #CourseModuleElementUserLogs Quiz Data
      @quizzes_this_month = @quiz_logs.this_month.count | 0
      @quizzes_one_month_ago = @quiz_logs.one_month_ago.count | 0
      @quizzes_two_months_ago = @quiz_logs.two_months_ago.count | 0
      @quizzes_three_months_ago = @quiz_logs.three_months_ago.count | 0
      @quizzes_four_months_ago = @quiz_logs.four_months_ago.count | 0
      @quizzes_five_months_ago = @quiz_logs.five_months_ago.count | 0

    end
  end

end
