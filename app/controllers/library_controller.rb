class LibraryController < ApplicationController

  before_action :check_course_available, :get_course_products_and_resources,
                only: [:course_show, :course_preview]


  def index
    @groups = Group.all_active.all_in_order
    if current_user && current_user.preferred_exam_body_id
      @groups = @groups.where(exam_body_id: current_user.preferred_exam_body_id)
    end
    redirect_to library_group_url(@groups.first.name_url) unless @groups.count > 1
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
    # Course Data necessary for logged out state
    tag_manager_data_layer(@course.name)
    seo_title_maker(@course.name, @course.description, nil)
    @form_type = "Course Tutor Question. Course: #{@course.name}"
    @course_tutor_details = @course.course_tutor_details.all_in_order

    if @course && !@course.preview
      if current_user
        # exam_body_user_details modal form variable and any session errors
        @exam_body_user_details = @course.exam_body.exam_body_user_details.for_user(
            current_user.id).last
        unless @exam_body_user_details
          @exam_body_user_details = current_user.exam_body_user_details.build(
              exam_body_id: @course.exam_body_id
          )
        end
        if session[:user_exam_body_errors]
          current_user.errors.add(:base, 'Details entered are not valid!')
          session[:user_exam_body_errors] = nil
        end

        if current_user.subject_course_user_logs.for_subject_course(@course.id).any?
          # Find the latest SCUL record for this user/course combination
          @subject_course_user_log = current_user.subject_course_user_logs.for_subject_course(@course.id).all_in_order.last
          @cmeuls = @subject_course_user_log.course_module_element_user_logs.all.map(&:course_module_element_id)
          @completed_cmeuls = @subject_course_user_log.course_module_element_user_logs.all_completed
          @completed_cmeuls_cme_ids = @completed_cmeuls.map(&:course_module_element_id)
          @incomplete_cmeuls = @subject_course_user_log.course_module_element_user_logs.all_incomplete
          @incomplete_cmeuls_cme_ids = @incomplete_cmeuls.map(&:course_module_element_id)

          @enrollment = @subject_course_user_log.enrollments.for_course_and_user(@course.id, current_user.id).all_in_order.last
          get_enrollment_form_variables(@course, @subject_course_user_log) if (@enrollment && @enrollment.expired) || !@enrollment

        else
          get_enrollment_form_variables(@course, nil)
        end
      end
    else
      render 'course_preview'
    end
  end

  def tutor_contact_form
    user_id = current_user ? current_user.id : nil
    IntercomCreateMessageWorker.perform_async(user_id, params[:email_address], params[:full_name],
                                              params[:question], params[:type])
    flash[:success] = 'Thank you! Your submission was successful. We will contact you shortly.'
    redirect_to request.referrer
  end


  protected

  def check_course_available
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    if @course && !@course.active
      redirect_to library_url
    elsif @course && @course.active && @course.preview

    end
  end

  def get_course_products_and_resources
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @currency_id = @country ? @country.currency_id : Currency.all_active.all_in_order.first
    @correction_pack_products = Product.includes(:currency)
                           .in_currency(@currency_id)
                           .all_active
                           .all_in_order
                           .where("mock_exam_id IS NOT NULL")
                           .where("product_type = ?", Product.product_types[:correction_pack])
    mock_exam_ids = @course.mock_exams.map(&:id)
    @mock_exam_products = Product.includes(:mock_exam)
                     .in_currency(@currency_id)
                     .all_active
                     .all_in_order
                     .where(mock_exam_id: mock_exam_ids)
    @products = @correction_pack_products + @mock_exam_products
    @subject_course_resources = @course.subject_course_resources.all_active.all_in_order

  end

  def get_enrollment_form_variables(course, scul=nil)
    if course.computer_based
      @computer_exam_sitting = ExamSitting.where(active: true, computer_based: true,
                                                 exam_body_id: course.exam_body_id,
                                                 subject_course_id: course.id).all_in_order.first #Should only be one
    else
      @exam_sittings = ExamSitting.where(active: true, computer_based: false,
                                         subject_course_id: course.id,
                                         exam_body_id: course.exam_body_id).all_in_order
    end

    @new_enrollment = Enrollment.new(subject_course_user_log_id: scul.try(:id),
                                     subject_course_id: course.id, exam_body_id: course.exam_body_id)
  end


end
