class CorporateRequestsController < ApplicationController

  before_action :logged_in_required, except: [:new, :create]
  before_action except: [:new, :create] do
    ensure_user_is_of_type(['admin'])
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
      flash[:success] = I18n.t('controllers.corporate_requests.create.flash.success')
      redirect_to request.referrer
      Mailers::OperationalMailers::SendCorporateEnquiryWorker.perform_async(@corporate_request)

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
    params.require(:corporate_request).permit(:name, :title, :company, :email, :phone_number, :website, :personal_message)
  end

end
