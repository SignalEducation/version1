class InvoicesController < ApplicationController

  before_action :logged_in_required
  before_action except: [:index, :show] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables
  before_action :bounce_to_index, except: [:index, :show]

  def index
    if current_user.admin?
      @invoices = Invoice.paginate(per_page: 50, page: params[:page]).all_in_order
    else
      @invoices = current_user.invoices.paginate(per_page: 50, page: params[:page]).all_in_order
    end
  end

  def show
    unless @invoice.try(:id)
      bounce_to_index
    end
  end

  def new
    @invoice = Invoice.new
  end

  def edit
  end

  def create
    @invoice = Invoice.new(allowed_params)
    @invoice.user_id = current_user.id
    if @invoice.save
      flash[:success] = I18n.t('controllers.invoices.create.flash.success')
      redirect_to invoices_url
    else
      render action: :new
    end
  end

  def update
    if @invoice.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.invoices.update.flash.success')
      redirect_to invoices_url
    else
      render action: :edit
    end
  end

  def destroy
    if @invoice.destroy
      flash[:success] = I18n.t('controllers.invoices.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.invoices.destroy.flash.error')
    end
    redirect_to invoices_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @invoice = current_user.admin? ?
              Invoice.where(id: params[:id]).first :
              current_user.invoices.where(id: params[:id]).first
    end
    # @users = User.all_in_order
    # @corporate_customers = CorporateCustomer.all_in_order
    # @subscriptions = Subscription.all_in_order
    @currencies = Currency.all_active.all_in_order
    # todo VAT processing disabled: @vat_rates = VatRate.all_in_order
    seo_title_maker(@invoice.try(:id).to_s)
  end

  def allowed_params
    params.require(:invoice).permit(:user_id, :corporate_customer_id, :subscription_transaction_id, :subscription_id, :number_of_users, :currency_id, :unit_price_ex_vat, :line_total_ex_vat, :vat_rate_id, :line_total_vat_amount, :line_total_inc_vat)
  end

  def bounce_to_index
    flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
    redirect_to invoices_url
    false
  end

end
