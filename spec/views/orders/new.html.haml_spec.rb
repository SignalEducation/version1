require 'rails_helper'

RSpec.describe 'orders/new', type: :view do
  before(:each) do
    x = FactoryGirl.create(:product)
    @products = Product.all
    x = FactoryGirl.create(:subject_course)
    @subject_courses = SubjectCourse.all
    x = FactoryGirl.create(:user)
    @users = User.all
    x = FactoryGirl.create(:stripe_customer)
    @stripe_customers = StripeCustomer.all
    @order = FactoryGirl.build(:order)
  end

  it 'renders edit order form' do
    render
    assert_select 'form[action=?][method=?]', orders_path, 'post' do
      assert_select 'select#order_product_id[name=?]', 'order[product_id]'
      assert_select 'select#order_subject_course_id[name=?]', 'order[subject_course_id]'
      assert_select 'select#order_user_id[name=?]', 'order[user_id]'
      assert_select 'input#order_stripe_guid[name=?]', 'order[stripe_guid]'
      assert_select 'select#order_stripe_customer_id[name=?]', 'order[stripe_customer_id]'
      assert_select 'input#order_live_mode[name=?]', 'order[live_mode]'
      assert_select 'input#order_current_status[name=?]', 'order[current_status]'
      assert_select 'input#order_coupon_code[name=?]', 'order[coupon_code]'
    end
  end
end
