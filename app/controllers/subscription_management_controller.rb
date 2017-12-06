class SubscriptionManagementController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(user_management_access))
  end
  before_action :get_variables


  def index

  end

  def show
    @subscription = Subscription.where(id: params[:id]).first
    @user = @subscription.user
  end

  def invoice
    @subscription = Subscription.where(id: params[:subscription_management_id]).first
    @invoice = Invoice.where(id: params[:invoice_id]).first
    @user = @invoice.user
    @charges = @invoice.charges
  end

  def pdf_invoice
    invoice = Invoice.where(id: params[:invoice_id]).first
    if invoice
      @invoice = invoice
      @invoice_date = invoice.issued_at
      description = t("views.general.subscription_in_months.a#{@invoice.subscription.subscription_plan.payment_frequency_in_months}")
      if @invoice.vat_rate
        vat_rate = @invoice.vat_rate.percentage_rate.to_s + '%'
      else
        vat_rate = '0%'
      end
      respond_to do |format|
        format.html
        format.pdf do
          pdf = InvoiceDocument.new(@invoice, view_context, description, vat_rate, @invoice_date)
          send_data pdf.render, filename: "invoice_#{@invoice.created_at.strftime("%d/%m/%Y")}.pdf", type: "application/pdf", disposition: "inline"
        end
      end
    else
      redirect_to users_url
    end
  end

  def charge
    @subscription = Subscription.where(id: params[:subscription_management_id]).first
    @invoice = Invoice.where(id: params[:invoice_id]).first
    @charge = Charge.where(id: params[:id]).first
    @subscription = @invoice.subscription
    @user = @invoice.user
    @charges = @invoice.charges
  end

  def un_cancel_subscription
    @subscription = Subscription.where(id: params[:subscription_management_id]).first
    if @subscription && @subscription.current_status == 'canceled-pending'
      @subscription.un_cancel

      if @subscription && @subscription.errors.count == 0
        flash[:success] = I18n.t('controllers.subscription_management.un_cancel_subscription.flash.success')
      else
        Rails.logger.error "ERROR: SubscriptionManagement#un_cancel_subscription - something went wrong. Errors:#{@subscription.errors.inspect}"
        flash[:error] = I18n.t('controllers.subscription_management.un_cancel_subscription.flash.error')
      end
      redirect_to subscription_management_url(@subscription)
    else
      flash[:error] = I18n.t('controllers.subscription_management.un_cancel_subscription.flash.not_pending_sub')
      redirect_to subscription_management_url(@subscription)
    end
  end

  def cancel
    # Set Subscription to canceled-pending
    @subscription = Subscription.where(id: params[:subscription_management_id]).first
    if @subscription.cancel
      flash[:success] = I18n.t('controllers.subscription_management.cancel.flash.success')
    else
      Rails.logger.warn "WARN: SubscriptionManagement#cancel failed to cancel a subscription. Errors:#{@subscription.errors.inspect}"
      flash[:error] = I18n.t('controllers.subscription_management.cancel.flash.error')
    end
    redirect_to subscription_management_url(@subscription)
  end

  def immediate_cancel
    # Set Subscription to canceled
    @subscription = Subscription.where(id: params[:subscription_management_id]).first
    if @subscription.immediate_cancel
      flash[:success] = I18n.t('controllers.subscription_management.immediately_cancel.flash.success')
    else
      Rails.logger.warn "WARN: SubscriptionManagement#immediately_cancel failed to cancel a subscription. Errors:#{@subscription.errors.inspect}"
      flash[:error] = I18n.t('controllers.subscription_management.immediately_cancel.flash.error')
    end
    redirect_to subscription_management_url(@subscription)
  end


  protected

  def get_variables
    @layout = 'management'

  end

end