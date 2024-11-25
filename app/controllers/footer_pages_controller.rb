# frozen_string_literal: true

class FooterPagesController < ApplicationController
  before_action :logged_in_required
  before_action :get_variables, except: :missing_page

  def privacy_policy
    seo_title_maker('Read Our Privacy Policy | Learnsignal', 'Read the Privacy Policy for learnsignal.com. Find out about our privacy and cookies policy here including how your data is used.', nil)
  end

  def acca_info
    seo_title_maker('ACCA Information | Learnsignal', 'This ACCA guideline from learnsignal provides information on exams, EPSM and PER and links to key ACCA resources to help you get your ACCA qualification.', nil)
  end

  def contact
    @form_type = 'Contact Us'
    seo_title_maker('Contact Us Today | Learnsignal',
                    "Contact us if you have any queries about learnsignal's online learning courses. Let us know if you have any specific feedback or complaints regarding our services.",
                    nil)
  end

  def terms_and_conditions
    @content_page = ContentPage.where(public_url: 'terms_and_conditions').all_active.first

    if @content_page
      seo_title_maker(@content_page.seo_title, @content_page.seo_description, nil)
      render 'content_pages/show'
    else
      seo_title_maker('Terms and Conditions', 'These terms and conditions ("Terms and Conditions") govern your use learnsignal.com ("Website") and the services offered herein (the “Services”). In these Terms and Conditions, Signal Education Limited is referred to as the “Company".', nil)
      render 'terms_and_conditions'
    end
  end

  def frequently_asked_questions
    seo_title_maker('Frequently Asked Questions | Learnsignal', "Find answers to learnsignal's frequently asked questions. If you have a question that you can't see the answer to don't hesitate to get in touch.", nil)
    @faq_section = FaqSection.all_active.all_in_order
  end

  def media_library
    @group        = Group.find_by(name_url: params[:group_name_url])
    @currency_id  = user_currency_id
    if @group&.exam_body&.has_products?
      seo_title_maker(@group.exam_body.products_seo_title, @group.exam_body.products_seo_description, false)
      valid_products = Product.for_group(@group.id).in_currency(@currency_id).all_active.all_in_order
    else
      seo_title_maker('Mock Exams and Correction Packs | Learnsignal', 'Get access to question and solution correction packs and mock exams designed by experts to help you pass your exams the first time.', nil)
      valid_products = Product.in_currency(@currency_id).all_active.all_in_order
    end
    @products      = valid_products.where('mock_exam_id IS NOT NULL OR cbe_id IS NOT NULL').
                       where('product_type IN (?)', [Product.product_types[:mock_exam], Product.product_types[:cbe]])
    @questions     = valid_products.where('mock_exam_id IS NOT NULL').
                       where('product_type = ?', Product.product_types[:correction_pack]).order(:group_id).limit(3)
  end

  def profile
    @tutor = User.all_tutors.where(name_url: params[:name_url]).first

    if @tutor&.course_tutors&.any?
      @course_ids = []
      @tutor.course_tutors.each do |course_tutor|
        @course_ids << course_tutor.course if course_tutor.course
      end
      @courses = Course.where(id: @course_ids)
      seo_title_maker("#{@tutor.full_name} Tutor | Learnsignal", @tutor.description, nil)
    else
      redirect_to tutors_url
    end

    @navbar = true
    @top_margin = true
  end

  def profile_index
    # /profiles
    @tutors = User.all_tutors.with_course_tutors.where.not(profile_image_file_name: nil)
    seo_title_maker('Learn About Our Tutors | Learnsignal', 'Our tutors are dedicated helping students achieve their learning goals. Read profiles of the industry experts that create learnsignal’s online courses.', nil)
    @navbar = true
    @top_margin = true
  end

  def missing_page
    if params[:first_element].to_s == '' && current_user
      redirect_to student_dashboard_url
    elsif params[:first_element].to_s == '500-page'
      render file: 'public/500.html', layout: nil, status: :internal_server_error
    else
      @top_margin = true
      render 'footer_pages/404_page.html.haml', status: :not_found
    end
    seo_title_maker('404 Page', "Sorry, we couldn't find what you are looking for. We missed the mark!
      but don't worry. We're working on fixing this link.", nil)
  end

  protected

  def get_variables
    @navbar     = 'standard'
    @top_margin = true
    @footer     = true
  end

  def user_currency_id
    if current_user
      return current_user.currency_id if current_user.currency_locked?

      country = IpAddress.get_country(request.remote_ip) || current_user.country
      currency = current_user.get_currency(country)
      currency_id = currency.id
    else
      country = IpAddress.get_country(request.remote_ip) || Country.find_by(name: 'United Kingdom')
      currency_id = country.currency_id
    end

    currency_id
  end
end
