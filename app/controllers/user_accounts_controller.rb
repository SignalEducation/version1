class UserAccountsController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables


  def account_show
    @orders = @user.orders
    @enrollments = @user.enrollments.all_active
    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
    @current_subscription = @user.current_subscription
    @invoices = @user.invoices

    #Restoring errors that could arise for user updating personal details in modal
    if session[:user_update_errors] && session[:valid_params]
      session[:user_update_errors].each do |k, v|
        v.each { |err| @user.errors.add(k, err) }
      end
      @user.first_name = session[:valid_params][0]
      @user.last_name = session[:valid_params][1]
      @user.email = session[:valid_params][2]
      @user.date_of_birth = session[:valid_params][3]
      session.delete(:user_update_errors)
      session.delete(:valid_params)
    end
  end

  def update_user
    if @user && @user.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.users.update.flash.success')
      redirect_to account_url
    else
      session[:user_update_errors] = @user.errors unless @user.errors.empty?
      session[:valid_params] = [@user.first_name, @user.last_name, @user.email, @user.date_of_birth] unless @user.errors.empty?
      redirect_to account_url(anchor: 'personal-details-modal')
    end
  end

  def change_password
    if @user.change_the_password(change_password_params)
      flash[:success] = I18n.t('controllers.users.change_password.flash.success')
      redirect_to account_url
    else
      flash[:error] = I18n.t('controllers.users.change_password.flash.error')
      redirect_to account_url(anchor: 'change-password-modal')
    end
  end

  def subscription_invoice
    invoice = Invoice.where(id: params[:id]).first
    if invoice && invoice.user_id == current_user.id
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
      redirect_to account_url
    end
  end


  protected

  def change_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def allowed_params
    params.require(:user).permit(:email, :first_name, :last_name, :address, :date_of_birth, :student_number,
    :unsubscribed_from_emails)
  end

  def get_variables
    @user = current_user
    seo_title_maker('Account Details', '', true)
  end

end