# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  corporate_customer_id       :integer
#  subscription_transaction_id :integer
#  subscription_id             :integer
#  number_of_users             :integer
#  currency_id                 :integer
#  vat_rate_id                 :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  issued_at                   :datetime
#  stripe_guid                 :string
#  sub_total                   :decimal(, )      default(0.0)
#  total                       :decimal(, )      default(0.0)
#  total_tax                   :decimal(, )      default(0.0)
#  stripe_customer_guid        :string
#  object_type                 :string           default("invoice")
#  payment_attempted           :boolean          default(FALSE)
#  payment_closed              :boolean          default(FALSE)
#  forgiven                    :boolean          default(FALSE)
#  paid                        :boolean          default(FALSE)
#  livemode                    :boolean          default(FALSE)
#  attempt_count               :integer          default(0)
#  amount_due                  :decimal(, )      default(0.0)
#  next_payment_attempt_at     :datetime
#  webhooks_delivered_at       :datetime
#  charge_guid                 :string
#  subscription_guid           :string
#  tax_percent                 :decimal(, )
#  tax                         :decimal(, )
#  original_stripe_data        :text
#

class InvoicesController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables

  def index
    if current_user.admin?
      @invoices = Invoice.paginate(per_page: 50, page: params[:page]).all_in_order
    else
      @invoices = current_user.invoices.where('total > 0.0').paginate(per_page: 50, page: params[:page]).all_in_order
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
    seo_title_maker(@invoice.try(:id).to_s, '', true)
  end

  def bounce_to_profile
    flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
    redirect_to account_url
    false
  end

end
