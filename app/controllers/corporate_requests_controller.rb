# == Schema Information
#
# Table name: corporate_requests
#
#  id               :integer          not null, primary key
#  name             :string
#  title            :string
#  company          :string
#  email            :string
#  phone_number     :string
#  website          :string
#  personal_message :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CorporateRequestsController < ApplicationController

  before_action :logged_in_required, except: [:new, :create, :submission_complete]
  before_action except: [:new, :create, :submission_complete] do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables

  def index
    @corporate_requests = CorporateRequest.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def submission_complete
  end

  def new
    @corporate_request = CorporateRequest.new
  end

  def edit
  end

  def create
    @corporate_request = CorporateRequest.new(allowed_params)
    if @corporate_request.save
      redirect_to submission_complete_url
      get_zendesk
      create_ticket = corporate_request_zendesk(@corporate_request.name, @corporate_request.company, @corporate_request.email, @corporate_request.phone_number) unless Rails.env.test?
    else
      redirect_to request.referrer
    end
  end

  def update
    if @corporate_request.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.corporate_requests.update.flash.success')
      redirect_to corporate_requests_url
    else
      render action: :edit
    end
  end


  def destroy
    if @corporate_request.destroy
      flash[:success] = I18n.t('controllers.corporate_requests.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.corporate_requests.destroy.flash.error')
    end
    redirect_to corporate_requests_url
  end

  def corporate_request_zendesk(name, company, email, phone_number)
    options = {:subject => 'Corporate Enquiry', :description => "Name: #{name} Company Name: #{company} - Phone Number: #{phone_number}", :requester => { :email => email, :name => name }}
    request = ZendeskAPI::Ticket.create(@client, options)
    if request.created_at
      flash[:success] = 'Thank you! Your submission was successful. We will contact you shortly.'
    else
      flash[:error] = 'Your submission was not successful. Please try again or email us directly at support@learnsignal.com'
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @corporate_request = CorporateRequest.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:corporate_request).permit(:name, :title, :company, :email, :phone_number, :website, :personal_message)
  end

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

end
