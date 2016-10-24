require 'rails_helper'

RSpec.describe 'orders/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @product = FactoryGirl.create(:product)
    @subject_course = FactoryGirl.create(:subject_course)
    @user = FactoryGirl.create(:user)
    @stripe_customer = FactoryGirl.create(:stripe_customer)
    temp_orders = FactoryGirl.create_list(:order, 2, product_id: @product.id, subject_course_id: @subject_course.id, user_id: @user.id, stripe_customer_id: @stripe_customer.id)
    @orders = Order.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of orders' do
    render
    expect(rendered).to match(/#{@orders.first.product.name.to_s}/)
    expect(rendered).to match(/#{@orders.first.subject_course.name.to_s}/)
    expect(rendered).to match(/#{@orders.first.user.name.to_s}/)
    expect(rendered).to match(/#{@orders.first.stripe_guid.to_s}/)
    expect(rendered).to match(/#{@orders.first.stripe_customer.name.to_s}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@orders.first.current_status.to_s}/)
    expect(rendered).to match(/#{@orders.first.coupon_code.to_s}/)
  end
end
