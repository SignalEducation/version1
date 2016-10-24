require 'rails_helper'

RSpec.describe 'orders/show', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @product = FactoryGirl.create(:product)
    @subject_course = FactoryGirl.create(:subject_course)
    @user = FactoryGirl.create(:user)
    @stripe_customer = FactoryGirl.create(:stripe_customer)
    @order = FactoryGirl.create(:order, product_id: @product.id, subject_course_id: @subject_course.id, user_id: @user.id, stripe_customer_id: @stripe_customer.id)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/#{@order.product.name}/)
    expect(rendered).to match(/#{@order.subject_course.name}/)
    expect(rendered).to match(/#{@order.user.name}/)
    expect(rendered).to match(/#{@order.stripe_guid}/)
    expect(rendered).to match(/#{@order.stripe_customer.name}/)
    expect(rendered).to match(/nice_boolean/)
    expect(rendered).to match(/#{@order.current_status}/)
    expect(rendered).to match(/#{@order.coupon_code}/)
  end
end
