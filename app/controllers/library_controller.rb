class LibraryController < ApplicationController

  before_action :logged_in_required, only: [:cert]

  def index
    @groups = Group.all_active.all_in_order
    seo_title_maker('Library', 'Learn anytime, anywhere from our library of business-focused courses taught by expert tutors.', nil)
  end

  def group_show
    @group = Group.find_by_name_url(params[:group_name_url])
    if @group
      @courses = @group.active_children.all_in_order
      seo_title_maker(@group.name, @group.description, nil)
      tag_manager_data_layer(@group.try(:name))
    else
      redirect_to library_url
    end
  end

  def course_show
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    if @course && @course.active && @course.live
      @course_modules = @course.children.all_active.all_in_order
      @tuition_course_modules = @course_modules.all_tuition
      @test_course_modules = @course_modules.all_test
      @revision_course_modules = @course_modules.all_revision
      @duration = @course.try(:total_video_duration) + @course.try(:estimated_time_in_seconds)
      tag_manager_data_layer(@course.try(:name))

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

      elsif current_user && @course.enrolled_user_ids.include?(current_user.id)
        #Get existing enrollment and try find an associated SCUL
        @enrollment = Enrollment.where(user_id: current_user.id).where(subject_course_id: @course.id).first
        if @enrollment
          @subject_course_user_log = @enrollment.subject_course_user_log
        end

        if current_user && current_user.permission_to_see_content(@course)
          @subject_course_resources = @course.subject_course_resources
        end

        @course_modules = @course.children.all_active.all_in_order
        @tuition_course_modules = @course_modules.all_tuition
        @test_course_modules = @course_modules.all_test
        @revision_course_modules = @course_modules.all_revision
        tag_manager_data_layer(@course.try(:name))
        @duration = @course.try(:total_video_duration) + @course.try(:estimated_time_in_seconds)

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
        @products = Product.includes(:currency).in_currency(@currency_id).all_active.all_in_order.where(mock_exam_id: mock_exam_ids)


        users_sets = StudentExamTrack.for_user_or_session(current_user.try(:id), current_session_guid).with_active_cmes.all_incomplete.all_in_order
        user_course_sets = users_sets.where(subject_course_id: @course.try(:id))
        latest_set = user_course_sets.first
        @latest_element_id = latest_set.try(:latest_course_module_element_id)
        @next_element = CourseModuleElement.where(id: @latest_element_id).first.try(:next_element)

        @cert = SubjectCourseUserLog.for_user_or_session(current_user.try(:id), current_session_guid).where(subject_course_id: @course.id).first
      end

    elsif @course && @course.active && !@course.live
      redirect_to preview_course_url
    else
      redirect_to library_url
    end
  end

  def preview_course
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    if @course && @course.active && !@course.live
      @course_modules = @course.children.all_active.all_in_order
      @tuition_course_modules = @course_modules.all_tuition
      @test_course_modules = @course_modules.all_test
      @revision_course_modules = @course_modules.all_revision
      @duration = @course.try(:total_video_duration) + @course.try(:estimated_time_in_seconds)
      tag_manager_data_layer(@course.try(:name))
    else
      redirect_to library_url
    end
  end

  def cert
    log = SubjectCourseUserLog.where(id: params[:id]).first
    certificate = CompletionCertificate.where(subject_course_user_log_id: log.id, user_id: log.user_id).first
    if certificate.nil?
      guid = SecureRandom.hex(10)
      @cert = CompletionCertificate.new(user_id: log.user_id)
      @cert.subject_course_user_log_id = log.id
      @cert.guid = guid
      if @cert.valid? && @cert.save
        respond_to do |format|
          format.html
          format.pdf do
            pdf = Certificate.new(@cert, view_context)
            send_data pdf.render, filename: "certificate_#{@cert.created_at.strftime("%d/%m/%Y")}.pdf", type: "application/pdf", page_layout: 'landscape', page_size: '2A0'
          end
        end
      end
    else
      @cert = certificate
      respond_to do |format|
        format.html
        format.pdf do
          pdf = Certificate.new(@cert, view_context)
          send_data pdf.render, filename: "certificate_#{@cert.created_at.strftime("%d/%m/%Y")}.pdf", type: "application/pdf", page_layout: 'landscape', page_size: '2A0'
        end
      end
    end
  end

  def subscribe
    email = params[:email][:address]
    list_id = params[:list_id]
    if !email.blank?
      begin
        @mc.lists.subscribe(list_id, {'email' => email})
        respond_to do |format|
          format.json{render json: {message: "Success! Check your email to confirm your subscription."}}
        end
      rescue Mailchimp::ListAlreadySubscribedError
        respond_to do |format|
          format.json{render json: {message: "#{email} is already subscribed to the list"}}
        end
      rescue Mailchimp::ListDoesNotExistError
        respond_to do |format|
          format.json{render json: {message: "The list could not be found."}}
        end
      rescue Mailchimp::Error => ex
        if ex.message
          respond_to do |format|
            format.json{render json: {message: "There is an error. Please enter valid email id."}}
          end
        else
          respond_to do |format|
            format.json{render json: {message: "An unknown error occurred."}}
          end
        end
      end
    else
      respond_to do |format|
        format.json{render json: {message: "Email Address Cannot be blank. Please enter valid email id."}}
      end
    end
  end


end
