class InvoicesController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables

  def index
    if current_user.admin?
      @invoices = Invoice.paginate(per_page: 50, page: params[:page]).all_in_order
    else
      @invoices = current_user.invoices.paginate(per_page: 50, page: params[:page]).all_in_order
    end
  end

  def show
    unless @invoice.try(:id)
      bounce_to_profile
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @invoice = current_user.admin? ?
              Invoice.where(id: params[:id]).first :
              current_user.invoices.where(id: params[:id]).first
    end
    @currencies = Currency.all_active.all_in_order
    # todo VAT processing disabled: @vat_rates = VatRate.all_in_order
    seo_title_maker(@invoice.try(:id).to_s)
  end

  def bounce_to_profile
    flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
    redirect_to profile_url
    false
  end

end
