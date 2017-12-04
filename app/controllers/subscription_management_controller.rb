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
    @invoice = Invoice.where(id: params[:invoice_id]).first
    @subscription = @invoice.subscription
    @user = @invoice.user
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

  protected

  def get_variables
    @layout = 'management'

  end

end