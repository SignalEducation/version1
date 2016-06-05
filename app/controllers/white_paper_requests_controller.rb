# == Schema Information
#
# Table name: white_paper_requests
#
#  id             :integer          not null, primary key
#  name           :string
#  email          :string
#  number         :string
#  company_name   :string
#  white_paper_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class WhitePaperRequestsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @white_paper_requests = WhitePaperRequest.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
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
    params.require(:white_paper_request).permit(:name, :email, :number, :company_name, :white_paper_id)
  end

end
