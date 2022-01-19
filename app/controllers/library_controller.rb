# frozen_string_literal: true

class LibraryController < ApplicationController
  before_action :logged_in_required
  before_action :check_course_available, :get_course_products_and_resources,
                only: %i[course_show course_preview]
  layout 'marketing'

  def index
    @groups = Group.all_active.with_active_body.all_in_order
    @home_page = HomePage.where(home: true).first
    redirect_to library_group_url(@groups.first.name_url) unless @groups.count > 1

    group_names = @groups.map(&:name).join(' and ')
    seo_title_maker('Library | Learnsignal',
                    'Discover professional courses designed by experts and delivered online so that you can study on a schedule that suits your needs.',
                    nil)
  end

  def group_show
    @group = Group.find_by(name_url: params[:group_name_url])

    if @group
      @levels  = @group.levels.all_active.all_in_order
      @courses = @group.active_children.all_in_order
      seo_title_maker(@group.seo_title, @group.seo_description, nil)
      tag_manager_data_layer(@group.try(:name))

      ip_country   = IpAddress.get_country(request.remote_ip)
      country      = ip_country || Country.find_by(name: 'United Kingdom')
      @currency_id = current_user ? current_user.get_currency(country).id : country.try(:currency_id)

      if country && @currency_id
        @subscription_plans =
          SubscriptionPlan.where(subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id).
            includes(:currency).in_currency(@currency_id).all_active.all_in_display_order.limit(3)

        @products = Product.for_group(@group.id).where(product_type: %i[lifetime_access program_access]).
                      includes(:currency).in_currency(@currency_id).all_active
      end
    else
      redirect_to root_url
    end
  end

  def course_show
    # Course Data necessary for logged out state
    tag_manager_data_layer(@course.name)
    seo_title_maker((@course.seo_title.presence || @course.name), @course.seo_description, nil)
    @form_type = "Course Tutor Question. Course: #{@course.name}"
    @course_tutors = @course.course_tutors.all_in_order
    country = IpAddress.get_country(request.remote_ip) || Country.find_by(name: 'United Kingdom')
    currency = current_user ? current_user.get_currency(country) : country.currency

    @subscription_plans = SubscriptionPlan.where(exam_body_id: @group.exam_body_id).
                            includes(:currency).in_currency(currency.id).all_active.all_in_display_order
    @course_product = Product.find_by(product_type: :program_access, course_id: @course.id, active: true, currency_id: currency.id)
    @lifetime_product = Product.find_by(product_type: :lifetime_access, course_id: nil, active: true, currency_id: currency.id, group_id: @group.id)

    if @course && @exam_body.active && !@course.preview
      if current_user
        @vimeo_as_main        = vimeo_as_main?
        @free_lesson          = @course.free_lesson
        @welcome_video        = @course.free_lesson.first_active_cme if @exam_body.new_onboarding && current_user.course_logs.empty?
        @valid_subscription   = current_user.active_subscriptions_for_exam_body(@exam_body.id).all_valid.first
        @course_log           = current_user.course_logs.for_course(@course.id).all_in_order.last

        if @course_log.present?
          @completed_course_lesson_logs  = @course_log.course_lesson_logs.all_complete
          @completed_course_lesson_ids   = @completed_course_lesson_logs.map(&:course_lesson_id)
          @cmeuls                        = @course_log.course_step_logs
          @cmeuls_ids                    = @cmeuls.map(&:course_step_id)
          @completed_cmeuls              = @cmeuls.all_completed
          @completed_cmeuls_cme_ids      = @completed_cmeuls.map(&:course_step_id)

          if @exam_body.has_sittings
            @exam_body_user_details = get_exam_body_user_details
            @enrollment = @course_log.enrollments.for_course_and_user(@course.id, current_user.id).all_in_order.last
            if @enrollment&.expired || !@enrollment
              get_enrollment_form_variables(@course, @course_log)
            end
          end

        else
          @exam_body_user_details = get_exam_body_user_details
          get_enrollment_form_variables(@course, nil) if @exam_body.has_sittings
        end
      end
    else
      render 'course_preview'
    end
  end

  def user_contact_form
    if invalid_email_format?(params[:email_address])
      flash[:modal_error] = 'Invalid email, please try again.'
    elsif verify_recaptcha(response: params['g_recaptcha_user_response_data'], model: @user, action: 'question', secret_key: Rails.application.credentials[Rails.env.to_sym][:google][:recaptcha][:secret_key]) && check_if_params_present
      Zendesk::RequestWorker.perform_async(params[:full_name],
                                           params[:email_address],
                                           params[:type],
                                           params[:question])

      flash[:modal_success] = 'Thank you! Your submission was successful. We will contact you shortly.'
    else
      flash[:modal_error] = 'Your submission was not successful. Please try again.'
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def check_if_params_present
    return true if params[:full_name].present? && params[:email_address].present? && params[:type].present? && params[:question].present?
  end

  def invalid_email_format?(email)
    !email.match(RFC822::EMAIL_REGEXP_WHOLE)
  end

  protected

  def check_course_available
    @course = Course.includes(course_lessons: { course_steps: :related_course_step }).
                find_by(name_url: params[:course_name_url])

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
    @exam_body_user_details = current_user.exam_body_user_details.for_exam_body(@course.exam_body_id).first
    @exam_body_user_details ||= current_user.exam_body_user_details.for_exam_body(@course.exam_body_id).build(exam_body_id: @course.exam_body_id)

    return unless session[:user_exam_body_errors]

    current_user.errors.add(:base, 'Details entered are not valid!')
    session[:user_exam_body_errors] = nil
  end

  def get_course_products_and_resources
    ip_country = IpAddress.get_country(request.remote_ip)
    country = ip_country || Country.find_by(name: 'United Kingdom')
    @correction_pack_products = []

    @currency_id =
      if current_user
        current_user.get_currency(country)
      else
        country ? country.currency : Currency.all_active.all_in_order.first
      end

    valid_products = Product.includes(:cbe).for_group(@group.id).
                       in_currency(@currency_id).all_active.all_in_order

    if @course.has_correction_packs
      @correction_pack_products = valid_products.
                                    where('mock_exam_id IS NOT NULL').
                                    where('product_type = ?', Product.product_types[:correction_pack])
    end
    cbes_ids            = @course.cbes.map(&:id)
    mock_exam_ids       = @course.mock_exams.map(&:id)
    @mock_exam_products = valid_products.
                            where('mock_exam_id IN (?) OR cbe_id IN (?)',
                                  mock_exam_ids, cbes_ids)

    @products = @mock_exam_products + @correction_pack_products

    @course_resources = @course.course_resources.all_active.all_in_order

    return unless country && @currency_id

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
                                                 course_id: course.id).all_in_order.first # Should only be one
    else
      @exam_sittings = ExamSitting.where(active: true, computer_based: false,
                                         course_id: course.id,
                                         exam_body_id: course.exam_body_id).all_in_order
    end

    @new_enrollment = Enrollment.new(course_log_id: scul.try(:id),
                                     course_id: course.id, notifications: false,
                                     exam_body_id: course.exam_body_id)
  end
end
