require 'rails_helper'

RSpec.describe 'invoices/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:user)
    @corporate_customer = FactoryGirl.create(:corporate_customer)
    @subscription_transaction = FactoryGirl.create(:subscription_transaction)
    @subscription = FactoryGirl.create(:subscription)
    @currency = FactoryGirl.create(:currency)
    @vat_rate = FactoryGirl.create(:vat_rate)
    @invoice = FactoryGirl.create(:invoice, user_id: @user.id, corporate_customer_id: @corporate_customer.id, subscription_transaction_id: @subscription_transaction.id, subscription_id: @subscription.id, currency_id: @currency.id, vat_rate_id: @vat_rate.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@invoice.user.name}/)
    expect(rendered).to match(/#{@invoice.corporate_customer.name}/)
    expect(rendered).to match(/#{@invoice.subscription_transaction.name}/)
    expect(rendered).to match(/#{@invoice.subscription.name}/)
    expect(rendered).to match(/#{@invoice.number_of_users}/)
    expect(rendered).to match(/#{@invoice.currency.name}/)
    expect(rendered).to match(/#{@invoice.unit_price_ex_vat}/)
    expect(rendered).to match(/#{@invoice.line_total_ex_vat}/)
    expect(rendered).to match(/#{@invoice.vat_rate.name}/)
    expect(rendered).to match(/#{@invoice.line_total_vat_amount}/)
    expect(rendered).to match(/#{@invoice.line_total_inc_vat}/)
  end
end
