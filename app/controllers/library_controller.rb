# frozen_string_literal: true

class LibraryController < ApplicationController
  before_action :check_course_available, :get_course_products_and_resources,
                only: %i[course_show course_preview]

  def index
    @groups = Group.all_active.with_active_body.all_in_order
    @home_page = HomePage.where(home: true).first
    redirect_to library_group_url(@groups.first.name_url) unless @groups.count > 1

    group_names = @groups.map(&:name).join(' and ')
    seo_title_maker("#{group_names} Professional Courses | LearnSignal",
                    'Discover professional courses designed by experts and delivered online so that you can study on a schedule that suits your needs.',
                    nil)
  end

  def group_show
    @group = Group.find_by(name_url: params[:group_name_url])

    if @group
      @courses = @group.active_children.all_in_order
      seo_title_maker(@group.seo_title, @group.seo_description, nil)
      tag_manager_data_layer(@group.try(:name))

      ip_country = IpAddress.get_country(request.remote_ip)
      country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
      @currency_id = current_user ? current_user.get_currency(country).id : country.try(:currency_id)

      if country && @currency_id
        @subscription_plans =
          SubscriptionPlan.where(subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id).
                           includes(:currency).in_currency(@currency_id).all_active.all_in_order.limit(3)
      end
    else
      redirect_to root_url
    end
  end

  def course_show
    # Course Data necessary for logged out state
    tag_manager_data_layer(@course.name)
    seo_title_maker(@course.seo_title, @course.seo_description, nil)
    @form_type = "Course Tutor Question. Course: #{@course.name}"
    @course_tutor_details = @course.course_tutor_details.all_in_order

    if @course && @exam_body.active && !@course.preview
      if current_user
        @valid_subscription = current_user.active_subscriptions_for_exam_body(@exam_body.id).all_valid.first

        if current_user.subject_course_user_logs.for_subject_course(@course.id).any?
          # Find the latest SCUL record for this user/course
          @subject_course_user_log = current_user.subject_course_user_logs.for_subject_course(@course.id).all_in_order.last
          @completed_student_exam_tracks = @subject_course_user_log.student_exam_tracks.all_complete
          @completed_course_module_ids = @completed_student_exam_tracks.map(&:course_module_id)
          @cmeuls = @subject_course_user_log.course_module_element_user_logs
          @cmeuls_ids = @cmeuls.map(&:course_module_element_id)
          @completed_cmeuls = @cmeuls.all_completed
          @completed_cmeuls_cme_ids = @completed_cmeuls.map(&:course_module_element_id)

          if @exam_body.has_sittings
            @exam_body_user_details = get_exam_body_user_details
            @enrollment = @subject_course_user_log.enrollments.for_course_and_user(@course.id, current_user.id).all_in_order.last
            if (@enrollment&.expired) || !@enrollment
              get_enrollment_form_variables(@course, @subject_course_user_log)
            end
          end

        else
          get_enrollment_form_variables(@course, nil) if @exam_body.has_sittings
        end

      end

    else
      render 'course_preview'
    end
  end

  protected

  def check_course_available
    @course = SubjectCourse.find_by(name_url: params[:subject_course_name_url])
    if @course&.active
      @group = @course.group
      @exam_body = @group.exam_body
    else
      redirect_to library_url
    end
  end

  def get_exam_body_user_details
    return unless @exam_body.has_sittings

    # exam_body_user_details modal form variable and any session errors
    @exam_body_user_details = @course.exam_body.exam_body_user_details.for_user(current_user.id).last
    @exam_body_user_details ||= current_user.exam_body_user_details.build(exam_body_id: @course.exam_body_id)

    return unless session[:user_exam_body_errors]

    current_user.errors.add(:base, 'Details entered are not valid!')
    session[:user_exam_body_errors] = nil
  end

  def get_course_products_and_resources
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country || Country.find_by(name: 'United Kingdom')
    @currency_id = @country ? @country.currency_id : Currency.all_active.all_in_order.first
    @correction_pack_products = []
    if @course.has_correction_packs
      @correction_pack_products = Product.includes(mock_exam: :subject_course).
                                    in_currency(@currency_id).
                                    all_active.
                                    all_in_order.
                                    where('mock_exam_id IS NOT NULL').
                                    where('product_type = ?', Product.product_types[:correction_pack])
    end
    mock_exam_ids = @course.mock_exams.map(&:id)
    @mock_exam_products = Product.includes(mock_exam: :subject_course).
        in_currency(@currency_id).
        all_active.
        all_in_order.
        where('product_type = ?', Product.product_types[:mock_exam]).
        where(mock_exam_id: mock_exam_ids)
    @products = @mock_exam_products + @correction_pack_products

    @subject_course_resources = @course.subject_course_resources.all_active.all_in_order

    return unless @country && @currency_id

    @subscription_plan =
      SubscriptionPlan.where(
        subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id,
        payment_frequency_in_months: @group.exam_body.try(:preferred_payment_frequency)
      ).in_currency(@currency_id).all_active.first
  end

  def get_enrollment_form_variables(course, scul = nil)
    if course.computer_based
      @computer_exam_sitting = ExamSitting.where(active: true, computer_based: true,
                                                 exam_body_id: course.exam_body_id,
                                                 subject_course_id: course.id).all_in_order.first # Should only be one
    else
      @exam_sittings = ExamSitting.where(active: true, computer_based: false,
                                         subject_course_id: course.id,
                                         exam_body_id: course.exam_body_id).all_in_order
    end

    @new_enrollment = Enrollment.new(subject_course_user_log_id: scul.try(:id),
                                     subject_course_id: course.id, notifications: false,
                                     exam_body_id: course.exam_body_id)
  end
end
