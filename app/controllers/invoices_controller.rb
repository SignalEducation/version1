# frozen_string_literal: true

class InvoicesController < ApplicationController
  before_action :logged_in_required
  before_action -> { ensure_user_has_access_rights(%w[user_management_access]) }, only: :show
  before_action -> { ensure_user_has_access_rights(%w[student_user user_management_access]) }, only: :pdf
  before_action :set_invoice, except: :index

  def index
    @invoices = current_user.invoices.valids.order(created_at: :desc)
  end

  def show
    @user   = @invoice.user
    @layout = 'management'
  end

  def update
    return_hash =
      case params[:status]
      when 'succeeded'
        @invoice.update(paid: true, payment_closed: true)
        { message: 'updated', status: :ok }
      else
        { error: 'something wrong happened, please check with admin team.', status: :error }
      end

    render json: return_hash
  end

  def pdf
    redirect_to account_url && return unless permission?

    # todo, move the creation of invoice to a work when invoice is created
    pdf = InvoiceDocument.new(@invoice)

    respond_to do |format|
      format.pdf do
        send_data pdf.render, filename: "invoice_#{@invoice.issued_at.strftime('%d/%m/%Y')}.pdf",
                              type: 'application/pdf',
                              disposition: 'inline'
      end
    end
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def permission?
    return true unless current_user.standard_student_user?

    # check if current user is the same as invoice user
    @invoice.user_id == current_user.id
  end
end
