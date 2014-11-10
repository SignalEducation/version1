require 'rails_helper'

RSpec.describe 'invoices/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @user = FactoryGirl.create(:individual_student_user)
    #@corporate_customer = FactoryGirl.create(:corporate_customer)
    @subscription_transaction = FactoryGirl.create(:payment_transaction)
    @subscription = FactoryGirl.create(:subscription)
    @currency = FactoryGirl.create(:currency)
    #@vat_rate = FactoryGirl.create(:vat_rate)
    temp_invoices = FactoryGirl.create_list(:invoice, 2, user_id: @user.id, corporate_customer_id: nil, subscription_transaction_id: @subscription_transaction.id, subscription_id: @subscription.id, currency_id: @currency.id, vat_rate_id: 1)  # todo @vat_rate.id)
    @invoices = Invoice.paginate(page: 1, per_page: 10)
  end

  xit 'renders a list of invoices' do
    render
    expect(rendered).to match(/#{@invoices.first.user.name.to_s}/)
    expect(rendered).to match(/#{@invoices.first.corporate_customer.name.to_s}/)
    expect(rendered).to match(/#{@invoices.first.subscription_transaction.name.to_s}/)
    expect(rendered).to match(/#{@invoices.first.subscription.name.to_s}/)
    expect(rendered).to match(/#{@invoices.first.number_of_users.to_s}/)
    expect(rendered).to match(/#{@invoices.first.currency.name.to_s}/)
    expect(rendered).to match(/#{@invoices.first.unit_price_ex_vat.to_s}/)
    expect(rendered).to match(/#{@invoices.first.line_total_ex_vat.to_s}/)
    expect(rendered).to match(/#{@invoices.first.vat_rate.name.to_s}/)
    expect(rendered).to match(/#{@invoices.first.line_total_vat_amount.to_s}/)
    expect(rendered).to match(/#{@invoices.first.line_total_inc_vat.to_s}/)
  end
end
