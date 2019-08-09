require 'rails_helper'

describe Admin::OrdersController, type: :controller do

  let!(:exam_body_1)         { FactoryBot.create(:exam_body) }
  let(:gbp)                  { create(:gbp) }
  let!(:uk)                  { create(:uk, currency: gbp) }
  let!(:uk_vat_code)         { create(:vat_code, country: uk) }

  let!(:student_user_group ) { create(:student_user_group ) }
  let!(:basic_student)       { create(:basic_student, user_group: student_user_group, preferred_exam_body_id: exam_body_1.id) }

  let!(:mock_exam_1)         { FactoryBot.create(:mock_exam) }
  let!(:product_1)           { FactoryBot.create(:product, currency_id: gbp.id, mock_exam_id: mock_exam_1.id, price: '99.9') }
  let!(:product_2)           { FactoryBot.create(:product, currency_id: gbp.id) }
  let!(:valid_params)        { FactoryBot.attributes_for(:order, product_id: product_1.id, stripe_token: 'tok_afsdafdfafsd') }
  let(:order_1)              { FactoryBot.create(:order, product_id: product_1.id,
                                                 stripe_customer_id: 'cus_fadsfdsf',
                                                 stripe_guid: 'dsafdsfdsfdf',
                                                 stripe_order_payment_data: { currency: gbp.iso_code },
                                                 stripe_status: 'paid') }
  let(:order_2)               { FactoryBot.create(:order, stripe_order_payment_data: { currency: gbp.iso_code }) }

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

    describe "GET 'show/#id'" do
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
  end
end
