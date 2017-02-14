class FooterPagesController < ApplicationController

  before_action :get_variables, except: [:missing_page]
  before_action :get_zendesk, only: [:complaints_zendesk, :contact_us_zendesk]

  def business
    @groups = Group.all_active.for_public.all_in_order
    seo_title_maker('Business Training Solutions', 'Adaptive training is a great resource for professionals, helping to solve problems when they happen. Professionals can access training courses on any device.', nil)
  end

  def why_learn_signal
    seo_title_maker('Why LearnSignal Training', 'Adaptive training is a great resource for professionals, helping to solve problems when they happen. Professionals can access training courses on any device.', nil)
  end

  def privacy_policy
    seo_title_maker('Privacy Policy', 'Privacy Policy of learnsignal.com. This Application collects some Personal Data from its Users.', nil)
  end

  def acca_info
    seo_title_maker('ACCA at LearnSignal', '', nil)
  end

  def contact
    seo_title_maker('Contact', 'If you have any queries or specific requests regarding LearnSignal’s online training faculty, get in touch with us, and a member of our team will contact you as soon as possible.', nil)
  end

  def terms_and_conditions
    seo_title_maker('Terms & Conditions', 'These terms and conditions ("Terms and Conditions") govern your use learnsignal.com ("Website") and the services offered herein (the “Services”). In these Terms and Conditions, Signal Education Limited is referred to as the “Company".', nil)
  end

  def missing_page
    if params[:first_element].to_s == '' && current_user
      redirect_to dashboard_special_link
    elsif params[:first_element].to_s == '500-page'
      render file: 'public/500.html', layout: nil, status: 500
    else
      render 'footer_pages/404_page.html.haml', status: 404
    end
    seo_title_maker('404 Page', "Sorry, we couldn't find what you are looking for. We missed the mark!
      but don't worry. We're working on fixing this link.", nil)
  end

  def info_subscribe
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

  def complaints_zendesk
    options = {:subject => params[:subject], :comment => { :value => params[:body] }, :requester => { :email => params[:email_address], :name => params[:full_name] }}
    request = ZendeskAPI::Ticket.create(@client, options)
    if request.created_at
      flash[:success] = 'Thank you! Your submission was successful. We will contact you shortly.'
    else
      flash[:error] = 'Your submission was not successful. Please try again or email us directly at support@learnsignal.com'
    end
    redirect_to contact_url
  end

  def contact_us_zendesk
    options = {:subject => "Basic Contact Us", :comment => { :value => params[:question] }, :requester => { :email => params[:email_address], :name => params[:full_name] }}
    request = ZendeskAPI::Ticket.create(@client, options)
    if request.created_at
      flash[:success] = 'Thank you! Your submission was successful. We will contact you shortly.'
    else
      flash[:error] = 'Your submission was not successful. Please try again or email us directly at support@learnsignal.com'
    end
    redirect_to contact_url
  end

  protected

  def get_zendesk
    require 'zendesk_api'
    @client = ZendeskAPI::Client.new do |config|
      config.url = "https://learnsignal.zendesk.com/api/v2"
      config.username = "james@learnsignal.com/token"
      config.token = ENV['learnsignal_zendesk_api_key'].to_s
      config.retry = true
      require 'logger'
      config.logger = Logger.new(STDOUT)
    end

  end

  def get_variables
    @navbar = false
  end
end
