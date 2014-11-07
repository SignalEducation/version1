require 'rails_helper'

RSpec.describe 'invoices/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:individual_student_user)
    @users = User.all
    x = FactoryGirl.create(:corporate_customer)
    @corporate_customers = CorporateCustomer.all
    x = FactoryGirl.create(:subscription_transaction)
    @subscription_transactions = SubscriptionTransaction.all
    x = FactoryGirl.create(:subscription)
    @subscriptions = Subscription.all
    x = FactoryGirl.create(:currency)
    @currencies = Currency.all
    x = FactoryGirl.create(:vat_rate)
    #@vat_rates = VatRate.all
    @invoice = FactoryGirl.build(:invoice)
  end

  it 'renders edit invoice form' do
    render
    assert_select 'form[action=?][method=?]', invoices_path, 'post' do
      assert_select 'select#invoice_user_id[name=?]', 'invoice[user_id]'
      assert_select 'select#invoice_corporate_customer_id[name=?]', 'invoice[corporate_customer_id]'
      assert_select 'select#invoice_subscription_transaction_id[name=?]', 'invoice[subscription_transaction_id]'
      assert_select 'select#invoice_subscription_id[name=?]', 'invoice[subscription_id]'
      assert_select 'input#invoice_number_of_users[name=?]', 'invoice[number_of_users]'
      assert_select 'select#invoice_currency_id[name=?]', 'invoice[currency_id]'
      assert_select 'input#invoice_unit_price_ex_vat[name=?]', 'invoice[unit_price_ex_vat]'
      assert_select 'input#invoice_line_total_ex_vat[name=?]', 'invoice[line_total_ex_vat]'
      assert_select 'select#invoice_vat_rate_id[name=?]', 'invoice[vat_rate_id]'
      assert_select 'input#invoice_line_total_vat_amount[name=?]', 'invoice[line_total_vat_amount]'
      assert_select 'input#invoice_line_total_inc_vat[name=?]', 'invoice[line_total_inc_vat]'
    end
  end
end
