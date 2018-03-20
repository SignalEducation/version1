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
    if @course && @course.active && !@course.preview
      # Course is active Data necessary for logged out state
      tag_manager_data_layer(@course.name)
      seo_title_maker(@course.name, @course.description, nil)
      @course_modules = CourseModule.includes(:course_module_elements).includes(:subject_course).where(subject_course_id: @course.id).all_active.all_in_order
      @tuition_course_modules = @course_modules.all_tuition.all_in_order
      @test_course_modules = @course_modules.all_test.all_in_order
      @revision_course_modules = @course_modules.all_revision.all_in_order

      ip_country = IpAddress.get_country(request.remote_ip)
      @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
      @currency_id = @country ? @country.currency_id : Currency.all_active.all_in_order.first
      mock_exam_ids = @course.mock_exams.map(&:id)
      @products = Product.includes(:mock_exam).in_currency(@currency_id).all_active.all_in_order.where(mock_exam_id: mock_exam_ids)



      if current_user
        # User Session present

        if current_user.permission_to_see_content && current_user.enrollment_for_course?(@course.id)
          # User has a valid trial or valid sub
          # User has an enrollment for this course

          @active_enrollment = current_user.enrollments.for_subject_course(@course.id).all_active.all_in_order.last
          @subject_course_user_log = @active_enrollment.subject_course_user_log

            if @active_enrollment.expired
              # User's enrollment is expired - needs to create a new one
              # User can view all links/buttons but they trigger the enrollment modal
              get_enrollment_form_variables(@course.id, @course.exam_body_id)
            else
              # User's enrollment is not expired - full access allowed
              # User can view and click on all links/buttons

              @latest_element_id = @subject_course_user_log.latest_course_module_element_id
              @next_element = CourseModuleElement.where(id: @latest_element_id).first.try(:next_element)
            end


            @completed_cmeuls = @subject_course_user_log.course_module_element_user_logs.all_completed
            @completed_cmeuls_cme_ids = @completed_cmeuls.map(&:course_module_element_id)
            @incomplete_cmeuls = @subject_course_user_log.course_module_element_user_logs.all_incomplete
            @incomplete_cmeuls_cme_ids = @incomplete_cmeuls.map(&:course_module_element_id)
            @subject_course_resources = @course.subject_course_resources
            @form_type = "Course Tutor Question. Course: #{@course.name}"

        else
          # Both modals need rendering
          # Enrollment and permission-denied
          get_enrollment_form_variables(@course.id, @course.exam_body_id)
        end
      end

    elsif @course && @course.active && @course.preview
      redirect_to library_preview_url(@course)
    else
      redirect_to library_url
    end
  end

  def course_preview
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    if @course && @course.active && @course.preview
      tag_manager_data_layer(@course.name)
      seo_title_maker(@course.name, @course.description, nil)
      ip_country = IpAddress.get_country(request.remote_ip)
      @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
      @currency_id = @country ? @country.currency_id : Currency.all_active.all_in_order.first
      mock_exam_ids = @course.mock_exams.map(&:id)
      @products = Product.includes(:mock_exam).in_currency(@currency_id).all_active.all_in_order.where(mock_exam_id: mock_exam_ids)

      @course_modules = CourseModule.includes(:course_module_elements).includes(:subject_course).where(subject_course_id: @course.id).all_active.all_in_order
      @tuition_course_modules = @course_modules.all_tuition.all_in_order
      @test_course_modules = @course_modules.all_test.all_in_order
      @revision_course_modules = @course_modules.all_revision.all_in_order

    else
      redirect_to library_url
    end
  end

  def tutor_contact_form
    user_id = current_user ? current_user.id : nil
    IntercomCreateMessageWorker.perform_async(user_id, params[:email_address], params[:full_name], params[:question], params[:type])
    flash[:success] = 'Thank you! Your submission was successful. We will contact you shortly.'
    redirect_to request.referrer
  end

  def get_enrollment_form_variables(course_id, exam_body_id)
    subject_course = SubjectCourse.find(course_id)

    @computer_exam_sitting = ExamSitting.where(active: true, computer_based: true, exam_body_id: subject_course.exam_body_id).all_in_order.first #Should only be one

    @exam_sittings = ExamSitting.where(active: true, computer_based: false, subject_course_id: course_id, exam_body_id: subject_course.exam_body_id).all_in_order

    @new_enrollment = Enrollment.new(subject_course_id: course_id, exam_body_id: exam_body_id)
  end

end
