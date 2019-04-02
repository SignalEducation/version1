class FooterPagesController < ApplicationController

  before_action :get_variables, except: [:missing_page]

  def privacy_policy
    seo_title_maker('Privacy Policy', 'Privacy Policy of learnsignal.com. This Application collects some Personal Data from its Users.', nil)
  end

  def acca_info
    seo_title_maker('ACCA at LearnSignal', '', nil)
  end

  def contact
    @form_type = 'Contact Us'
    seo_title_maker('Contact', 'If you have any queries or specific requests regarding LearnSignal’s online training faculty, get in touch with us, and a member of our team will contact you as soon as possible.', nil)
  end

  def terms_and_conditions
    @content_page = ContentPage.where(public_url: 'terms_and_conditions').all_active.first
    if @content_page
      seo_title_maker(@content_page.seo_title, @content_page.seo_description, nil)
      render 'content_pages/show'
    else
      seo_title_maker('Terms & Conditions', 'These terms and conditions ("Terms and Conditions") govern your use learnsignal.com ("Website") and the services offered herein (the “Services”). In these Terms and Conditions, Signal Education Limited is referred to as the “Company".', nil)
      render 'terms_and_conditions'
    end
  end

  def frequently_asked_questions
    seo_title_maker('FAQs', 'Frequently Asked Questions', nil)
    @faq_section = FaqSection.all_active.all_in_order
  end

  def media_library
    if current_user
      @country = current_user.country
    else
      ip_country = IpAddress.get_country(request.remote_ip)
      @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    end
    @currency_id = @country.currency_id
    @products = Product.includes(:currency)
                       .in_currency(@currency_id)
                       .all_active
                       .all_in_order
                       .where("mock_exam_id IS NOT NULL")
                       .where("product_type = ?", Product.product_types[:mock_exam])
    @questions = Product.includes(:currency)
                       .in_currency(@currency_id)
                       .all_active
                       .all_in_order
                       .where("mock_exam_id IS NOT NULL")
                       .where("product_type = ?", Product.product_types[:correction_pack])
  end

  def white_paper_request
    @white_paper = WhitePaper.where(name_url: params[:white_paper_name_url]).first
    @white_paper_request = WhitePaperRequest.new(white_paper_id: @white_paper.id)
  end


  def profile

    @tutor = User.all_tutors.where(name_url: params[:name_url]).first
    if @tutor && @tutor.course_tutor_details.any?
      @course_ids = []
      @tutor.course_tutor_details.each do |course_tutor|
        @course_ids << course_tutor.subject_course if course_tutor.subject_course
      end
      @courses = SubjectCourse.where(id: @course_ids)
      seo_title_maker(@tutor.full_name, @tutor.description, nil)
    else
      redirect_to tutors_url
    end
    @navbar = true
    @top_margin = true
  end

  def profile_index
    #/profiles
    @tutors = User.all_tutors.with_course_tutor_details.where.not(profile_image_file_name: nil)
    seo_title_maker('Our Lecturers', 'Learn from industry experts that create LearnSignal’s online courses.', nil)
    @navbar = true
    @top_margin = true
  end

  def missing_page
    if params[:first_element].to_s == '' && current_user
      redirect_to student_dashboard_url
    elsif params[:first_element].to_s == '500-page'
      render file: 'public/500.html', layout: nil, status: 500
    else
      @top_margin = true
      render 'footer_pages/404_page.html.haml', status: 404
    end
    seo_title_maker('404 Page', "Sorry, we couldn't find what you are looking for. We missed the mark!
      but don't worry. We're working on fixing this link.", nil)
  end

  def info_subscribe
    email = params[:email][:address]
    name = params[:first_name][:address]
    #list_id = '866fa91d62' # Dev List
    list_id = 'a716c282e2' # Production List
    if !email.blank?
      begin
        @mc.lists.subscribe(list_id, {'email' => email}, {'fname' => name})

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

  def complaints_intercom
    user_id = current_user ? current_user.id : nil
    IntercomCreateMessageWorker.perform_async(user_id, params[:email_address], params[:full_name], params[:body], 'Complaints Form')
    flash[:success] = 'Thank you! Your submission was successful. We will contact you shortly.'
    redirect_to contact_url
  end

  def contact_us_intercom
    user_id = current_user ? current_user.id : nil
    IntercomCreateMessageWorker.perform_async(user_id, params[:email_address], params[:full_name], params[:question], params[:type])
    flash[:success] = 'Thank you! Your submission was successful. We will contact you shortly.'
    redirect_to request.referrer ? request.referrer : root_url
  end

  protected

  def get_variables
    @navbar = 'standard'
    @top_margin = true
    @footer = true
  end

end
