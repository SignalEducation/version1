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
      @course_modules = CourseModule.where(tutor_id: current_user.id)
    end

    if @dashboard_type.include?('content_manager')
      @static_pages = StaticPage.all_in_order
      @edited_recently = @static_pages.where('updated_at > ?', Proc.new{Time.now - 3.days}.call)
      @recently_published = @static_pages.where('publish_from > ?', Time.now - 3.days)
      @publishes_soon = @static_pages.where('publish_from > ? AND publish_from < ?', Proc.new{Time.now}.call, Proc.new{Time.now + 3.days}.call)
      @recently_expired = @static_pages.where('publish_to IS NOT NULL AND publish_to < ? AND publish_to > ?', Proc.new{Time.now}.call, Proc.new{Time.now - 3.days}.call)
      @expires_soon = @static_pages.where('publish_to > ? AND publish_to < ?', Proc.new{Time.now}.call, Proc.new{Time.now + 3.days}.call)
    end

    if @dashboard_type.include?('admin')
      @all_users = User.all
      @active_users = @all_users.where(active: true)
      @new_users = @all_users.where('created_at > ?', Proc.new{Time.now - 7.days}.call)
      @all_user_groups = UserGroup.all
      @new_user_groups = @all_user_groups.where('created_at > ?', Proc.new{Time.now - 7.days}.call)
      @all_subject_areas = SubjectArea.all
      @active_subject_areas = @all_subject_areas.where(active: true)
      @new_subject_areas = @all_subject_areas.where('created_at > ?', Proc.new{Time.now - 7.days}.call)
      @all_institutions = Institution.all
      @active_institutions = @all_institutions.where(active: true)
      @new_institutions = @all_institutions.where('created_at > ?', Proc.new{Time.now - 7.days}.call)
      @all_qualifications = Qualification.all
      @active_qualifications = @all_qualifications.where(active: true)
      @new_qualifications = @all_qualifications.where('created_at > ?', Proc.new{Time.now - 7.days}.call)
      @all_exam_levels = ExamLevel.all
      @active_exam_levels = @all_exam_levels.where(active: true)
      @new_exam_levels = @all_exam_levels.where('created_at > ?', Proc.new{Time.now - 7.days}.call)
    end

  end

end
