class LibraryController < ApplicationController

  def index
    @groups = Group.all_active.all_in_order
    if @groups.count == 1
      @group = Group.all_active.all_in_order.first
      redirect_to library_group_url(@group.name_url)
    end
    seo_title_maker('Library', 'Learn anytime, anywhere from our library of business-focused courses taught by expert tutors.', nil)
  end

  def group_show
    @group = Group.find_by_name_url(params[:group_name_url])
    if @group
      @courses = @group.active_children.all_in_order
      seo_title_maker(@group.name, @group.description, nil)
      tag_manager_data_layer(@group.try(:name))
    else
      redirect_to root_url
    end
  end

  def course_show
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    if @course && @course.active
      @course_modules = CourseModule.includes(:course_module_elements).includes(:subject_course).where(subject_course_id: @course.id).all_in_order
      @tuition_course_modules = @course_modules.all_tuition.all_in_order
      @test_course_modules = @course_modules.all_test.all_in_order
      @revision_course_modules = @course_modules.all_revision.all_in_order
      tag_manager_data_layer(@course.name)

      #Enrollment and SubjectCourseUserLog
      if current_user && !@course.enrolled_user_ids.include?(current_user.id)
        #Make Enrollment Form and required params
        if @course.exam_body
          @exam_body = @course.exam_body
          @enrollments = @exam_body.enrollments.where(user_id: current_user.id)
          possible_student_number = @enrollments.map(&:student_number).first
        else
          possible_student_number = nil
        end
        @enrollment = Enrollment.new(student_number: possible_student_number)
        @exam_sittings = ExamSitting.where(subject_course_id: @course.id).all_in_order
        if current_user && current_user.permission_to_see_content(@course)
          @subject_course_resources = @course.subject_course_resources
        end
        @subject_course_user_log = SubjectCourseUserLog.for_user_or_session(current_user.try(:id), current_session_guid).where(subject_course_id: @course.id).all_in_order.first

      elsif current_user && @course.enrolled_user_ids.include?(current_user.id)
        #Get existing enrollment and try find an associated SCUL
        @enrollment = Enrollment.where(user_id: current_user.id).where(subject_course_id: @course.id).first
        if @enrollment
          @subject_course_user_log = @enrollment.subject_course_user_log
        end

        if current_user && current_user.permission_to_see_content(@course)
          @subject_course_resources = @course.subject_course_resources
        end

      else
        #As a backup try find a related SCUL
        @subject_course_user_log = SubjectCourseUserLog.for_user_or_session(current_user.try(:id), current_session_guid).where(subject_course_id: @course.id).all_in_order.first
      end

      if current_user
        mock_exams = @course.mock_exams
        mock_exam_ids = mock_exams.map(&:id)
        ip_country = IpAddress.get_country(request.remote_ip)
        @country = ip_country ? ip_country : current_user.country
        @currency_id = @country ? @country.currency_id : Currency.all_active.all_in_order.first
        @products = Product.includes(:mock_exam).in_currency(@currency_id).all_active.all_in_order.where(mock_exam_id: mock_exam_ids)


        users_sets = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).with_active_cmes.all_incomplete.all_in_order
        user_course_sets = users_sets.where(subject_course_id: @course.try(:id))
        latest_set = user_course_sets.first
        @latest_element_id = latest_set.try(:latest_course_module_element_id)
        @next_element = CourseModuleElement.where(id: @latest_element_id).first.try(:next_element)

      end

    else
      redirect_to library_url
    end
  end

end
