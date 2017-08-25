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

  def new
    @corporate_request = CorporateRequest.new
  end

  def edit
  end

  def create
    @corporate_request = CorporateRequest.new(allowed_params)
    if @corporate_request.save
      content = "Company: #{@corporate_request.company}, PhoneNumber: #{@corporate_request.phone_number}"

      user_id = current_user ? current_user.id : nil
      IntercomCreateMessageWorker.perform_async(user_id, @corporate_request.email, @corporate_request.name, content, params[:type])
      flash[:success] = 'Thank you! Your submission was successful. We will contact you shortly.'
      redirect_to request.referrer
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

  protected

  def get_variables
    if params[:id].to_i > 0
      @corporate_request = CorporateRequest.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:corporate_request).permit(:name, :title, :company, :email, :phone_number, :website, :personal_message, :type)
  end

end
