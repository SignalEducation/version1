class WhitePaperRequestsController < ApplicationController

  before_action :logged_in_required, except: [:create]
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @white_paper_requests = WhitePaperRequest.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def edit
  end

  def create
    @white_paper_request = WhitePaperRequest.new(allowed_params)
    if @white_paper_request.save
      flash[:success] = I18n.t('controllers.white_paper_requests.create.flash.success')
      redirect_to white_paper_requests_url
    else
      render action: :new
    end
  end

  def update
    if @white_paper_request.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.white_paper_requests.update.flash.success')
      redirect_to white_paper_requests_url
    else
      render action: :edit
    end
  end


  def destroy
    if @white_paper_request.destroy
      flash[:success] = I18n.t('controllers.white_paper_requests.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.white_paper_requests.destroy.flash.error')
    end
    redirect_to white_paper_requests_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @white_paper_request = WhitePaperRequest.where(id: params[:id]).first
    end
    @white_papers = WhitePaper.all_in_order
  end

  def allowed_params
    params.require(:white_paper_request).permit(:name, :email, :number, :web_url, :company_name, :white_paper_id)
  end

end
