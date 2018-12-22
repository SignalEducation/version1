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
      @course_tutor_details = @course.course_tutor_details.all_in_order
      # Course is active Data necessary for logged out state
      tag_manager_data_layer(@course.name)
      seo_title_maker(@course.name, @course.description, nil)

      ip_country = IpAddress.get_country(request.remote_ip)
      @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
      @currency_id = @country ? @country.currency_id : Currency.all_active.all_in_order.first
      mock_exam_ids = @course.mock_exams.map(&:id)
      @products = Product.includes(:mock_exam).in_currency(@currency_id).all_active.all_in_order.where(mock_exam_id: mock_exam_ids)
      @subject_course_resources = @course.subject_course_resources.all_active.all_in_order



      if current_user
        # User Session present
        if session[:user_exam_body_errors]
          current_user.errors.add(:base, 'Details entered are not valid!')
          session[:user_exam_body_errors] = nil
        end

        if current_user.subject_course_user_logs.for_subject_course(@course.id).any?
          @subject_course_user_log = current_user.subject_course_user_logs.for_subject_course(@course.id).first

          @latest_element_id = @subject_course_user_log.latest_course_module_element_id
          #TODO - @next_element can be a CME, CM or CS
          @next_element = CourseModuleElement.where(id: @latest_element_id).first.try(:next_element)

          @completed_cmeuls = @subject_course_user_log.course_module_element_user_logs.all_completed
          @completed_cmeuls_cme_ids = @completed_cmeuls.map(&:course_module_element_id)
          @incomplete_cmeuls = @subject_course_user_log.course_module_element_user_logs.all_incomplete
          @incomplete_cmeuls_cme_ids = @incomplete_cmeuls.map(&:course_module_element_id)
          @form_type = "Course Tutor Question. Course: #{@course.name}"

        else

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
    IntercomCreateMessageWorker.perform_async(user_id, params[:email_address], params[:full_name],
                                              params[:question], params[:type])
    flash[:success] = 'Thank you! Your submission was successful. We will contact you shortly.'
    redirect_to request.referrer
  end

end
