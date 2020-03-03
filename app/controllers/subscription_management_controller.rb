# frozen_string_literal: true

class SubscriptionManagementController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[user_management_access]) }
  before_action :management_layout
  before_action :set_subscription, except: %i[show pdf_invoice]
  before_action :set_invoice, only: %i[invoice pdf_invoice charge]

  def show
    @subscription = Subscription.find(params[:id])
    @user         = @subscription.user
  end

  def invoice
    @user    = @invoice.user
    @charges = @invoice.charges
  end

  def pdf_invoice
    if @invoice
      @invoice_date = @invoice.issued_at
      description   = t("views.general.subscription_in_months.a#{@invoice.subscription.subscription_plan.payment_frequency_in_months}")
      vat_rate      = @invoice.vat_rate ? @invoice.vat_rate.percentage_rate.to_s + '%' : '0%'

      respond_to do |format|
        format.html
        format.pdf do
          pdf = InvoiceDocument.new(@invoice, view_context, description, vat_rate, @invoice_date)
          send_data pdf.render, filename: "invoice_#{@invoice.created_at.strftime('%d/%m/%Y')}.pdf", type: 'application/pdf', disposition: 'inline'
        end
      end
    else
      redirect_to users_url
    end
  end

  def charge
    @charge       = Charge.find_by(id: params[:id])
    @subscription = @invoice.subscription
    @user         = @invoice.user
    @charges      = @invoice.charges
  end

  def cancellation
    @type    = params[:type]
    @layout  = 'management'
    @reasons = ['Duplicate Payment', 'Requested by customer', 'Other (Please provide note)']

    render :admin_new
  end

  def cancel_subscription
    if subscription_cancelled?(@subscription)
      flash[:success] = I18n.t('controllers.subscription_management.cancel.flash.success')
    else
      Rails.logger.warn "WARN: SubscriptionManagement#cancel failed to cancel a subscription. Errors:#{@subscription.errors.inspect}"
      flash[:error] = I18n.t('controllers.subscription_management.cancel.flash.error')
    end

    redirect_to subscription_management_url(@subscription)
  end

  def un_cancel_subscription
    if @subscription&.stripe_status == 'canceled-pending'
      @subscription.un_cancel

      if @subscription&.errors&.count&.zero?
        flash[:success] = I18n.t('controllers.subscription_management.un_cancel_subscription.flash.success')
      else
        Rails.logger.error "ERROR: SubscriptionManagement#un_cancel_subscription - something went wrong. Errors:#{@subscription.errors.inspect}"
        flash[:error] = I18n.t('controllers.subscription_management.un_cancel_subscription.flash.error')
      end
    else
      flash[:error] = I18n.t('controllers.subscription_management.un_cancel_subscription.flash.not_pending_sub')
    end

    redirect_to subscription_management_url(@subscription)
  end

  def reactivate_subscription
    if @subscription.reactivate_canceled
      flash[:success] = I18n.t('controllers.subscription_management.reactivate_canceled.flash.success')
    else
      Rails.logger.warn "WARN: SubscriptionManagement#reactivate_canceled failed to reactivate a subscription. Errors:#{@subscription.errors.inspect}"
      flash[:error] = I18n.t('controllers.subscription_management.reactivate_canceled.flash.error') << @subscription.errors[:base].to_s
    end

    redirect_to subscription_management_url(@subscription)
  end

  protected

  def set_subscription
    @subscription = Subscription.find(params[:subscription_management_id])
  end

  def set_invoice
    @invoice = Invoice.find_by(id: params[:invoice_id])
  end

  def subscription_params
    params.require(:subscription).permit(
      :cancellation_reason,
      :cancellation_note,
      :cancelled_by_id,
      :cancelling_subscription
    )
  end

  def subscription_cancelled?(subscription)
    ActiveRecord::Base.transaction do
      subscription.update(subscription_params)
      stripe_cancellation(subscription)
    end
  rescue Learnsignal::SubscriptionError => e
    flash[:error] = e.message
    redirect_to subscription_management_url(@subscription)
  end

  def stripe_cancellation(subscription)
    sub_service = SubscriptionService.new(subscription)

    case params[:type]
    when 'standard'
      sub_service.cancel_subscription
    when 'immediate'
      sub_service.cancel_subscription_immediately
    end
  end
end
