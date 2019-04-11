class InvoicesController < ApplicationController
  before_action :logged_in_required
  before_action :set_invoice, only: :show

  def index
    @invoices = current_user.invoices.order(created_at: :desc)
  end

  def show
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
    unless @invoice.user_id == current_user.id
      redirect_to user_invoies_path(current_user)
    end
  end
end
