# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  subject_course_id         :integer
#  user_id                   :integer
#  stripe_guid               :string
#  stripe_customer_id        :string
#  live_mode                 :boolean          default(FALSE)
#  stripe_status             :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default(FALSE)
#  reference_guid            :string
#  paypal_guid               :string
#  paypal_status             :string
#  state                     :string
#

require 'rails_helper'

describe OrdersController, type: :controller do

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:gbp) { create(:gbp) }
  let!(:uk) { create(:uk, currency: gbp) }
  let!(:uk_vat_code) { create(:vat_code, country: uk) }

  let!(:student_user_group ) { create(:student_user_group ) }
  let!(:basic_student) { create(:basic_student, user_group: student_user_group, preferred_exam_body_id: exam_body_1.id) }

  let!(:mock_exam_1) { FactoryBot.create(:mock_exam) }
  let!(:product_1) { FactoryBot.create(:product, currency_id: gbp.id, mock_exam_id: mock_exam_1.id, price: '99.9') }
  let!(:product_2) { FactoryBot.create(:product, currency_id: gbp.id) }
  let!(:order_1) { FactoryBot.create(:order, product_id: product_1.id) }
  let!(:order_2) { FactoryBot.create(:order) }
  let!(:valid_params) { FactoryBot.attributes_for(:order, product_id: product_1.id) }


  context 'Logged in as a valid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(basic_student)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see order_1' do
        get :show, params: { id: order_1.id }
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see order_2' do
        get :show, params: { id: order_2.id }
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, params: { product_id: product_1.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for valid params' do
        post :create, params: { order: valid_params }
        expect_create_success_with_model('order', orders_url)
      end

      xit 'should report error for invalid params' do
        post :create, params: { order: {valid_params.keys.first => ''} }
        expect_create_error_with_model('order')
      end
    end

  end

end
