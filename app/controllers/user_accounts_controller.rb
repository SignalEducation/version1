# frozen_string_literal: true
require 'securerandom'

class UserAccountsController < ApplicationController
  before_action :logged_in_required
  before_action :get_variables

  def account_show
    @orders = @user.orders
    @referral_code = @user.referral_code
    @enrollments = current_user.valid_enrollments_in_sitting_order

    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
    @default_payment_card = @subscription_payment_cards.all_default_cards.first
    @subscriptions = @user.viewable_subscriptions

    @invoices = @user.invoices
    @exam_body_user_details = @user.exam_body_user_details.where.not(student_number: nil)

    #ExamBody.where.not(id: @exam_body_user_details.map(&:exam_body_id)).all.each do |exam_body|
    #  #TODO - limit this to only exam bodies that have sittings (not CPD)
      # and where enrolments exist for this user
    #  @user.exam_body_user_details.build(exam_body_id: exam_body.id)
    #end
    seo_title_maker('View Your Account Details | LearnSignal',
                    'Log in to view your learnsignal account details including personal information, account information, orders, enrolments and referral program.',
                    false)

    #Restoring errors that could arise for user updating personal details in modal
    if session[:user_update_errors] && session[:valid_params]
      session[:user_update_errors].each do |k, v|
        v.each { |err| @user.errors.add(k, err) }
      end
      @user.first_name = session[:valid_params][0]
      @user.last_name = session[:valid_params][1]
      @user.email = session[:valid_params][2]
      @user.date_of_birth = session[:valid_params][3]
      session.delete(:user_update_errors)
      session.delete(:valid_params)
    end
  end

  def update_user
    if @user&.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.users.update.flash.success')
      redirect_to account_url
    else
      session[:user_update_errors] = @user.errors unless @user.errors.empty?
      session[:valid_params] = [@user.first_name, @user.last_name, @user.email, @user.date_of_birth] unless @user.errors.empty?
      redirect_to account_url(anchor: 'personal-details-modal')
    end
  end

  def change_password
    if @user.change_the_password(change_password_params)
      flash[:success] = I18n.t('controllers.users.change_password.flash.success')
    else
      flash[:error] = I18n.t('controllers.users.change_password.flash.error')
    end

    redirect_to account_url
  end

  def subscription_invoice
    redirect_to pdf_invoice_path(format: :pdf), params
  end


  def show_invoice
      # Get guid from url show_invoice/[guid]
      # This guid is sent by email
      # Confirm the user is allowed access to this invoice

      # Parse guid 
      # Check the user is authorized 
      # From invoice get stripe guid
      # Then call process with Stripe's call
      
      #sca_verification_guid = generate_sca_guid
      email_sca_guid = params['guid']
      
      #Check the guid belongs to this user

      #If it is then call stripe's payment intent
      
      @invoice = Invoice.find 54856

      stripe_invoice = Stripe::Invoice.retrieve(@invoice.stripe_guid)
      @the_secret = stripe_invoice.payment_intent.client_secret
  end

  def send_sca_email
    # Expecting the invoice guid to come in from stripe
    # Hard code for now
    @invoice = Invoice.find 54857

    guid = generate_sca_guid
    @invoice.update_attribute(:sca_verification_guid, guid)
    return guid
  end


  protected 

  def change_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def allowed_params
    params.require(:user).permit(:email, :first_name, :last_name,
                                 :address, :date_of_birth,
                                 :unsubscribed_from_emails,
                                 exam_body_user_details_attributes: [:id,
                                                                     :exam_body_id,
                                                                     :student_number])
  end

  def get_variables
    @user = current_user
    seo_title_maker('Account Details', '', true)
  end

  def generate_sca_guid
    SecureRandom.uuid
  end

end
