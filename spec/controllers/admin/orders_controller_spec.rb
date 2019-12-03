require 'rails_helper'

describe Admin::OrdersController, type: :controller do

  let!(:exam_body_1)         { FactoryBot.create(:exam_body) }
  let(:gbp)                  { create(:gbp) }
  let!(:uk)                  { create(:uk, currency: gbp) }
  let!(:uk_vat_code)         { create(:vat_code, country: uk) }

  let!(:user_management_user_group )  { create(:user_management_user_group ) }
  let!(:user_management_user)         { create(:user_management_user, user_group: user_management_user_group) }


  let!(:student_user_group)  { create(:student_user_group ) }
  let!(:basic_student)        { create(:basic_student, user_group: student_user_group, preferred_exam_body_id: exam_body_1.id) }

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

    describe '#update_product' do
      it 'should render update_product' do
        get :index
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a exercise_corrections_access user' do
    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe '#index' do
      it 'should render index' do
        get :index

        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
      end
    end

    describe '#update_product' do
      it 'should render update_product' do
        get :update_product, params: { order_id: order_1.id }

        expect(response.status).to eq(200)
        expect(response).to render_template(:update_product)
      end
    end

    describe '#update' do
      context 'update order product' do
        it 'should update product update_product' do
          patch :update, params: { id: order_1.id, order: { product_id: product_1.id } }

          expect(response.status).to eq(302)
          expect(response).to redirect_to(admin_order_path(order_1))
        end

        it 'should not update product update_product' do
          patch :update, params: { id: 666, order: { product_id: product_1.id } }

          expect(response.status).to eq(302)
          expect(response).to redirect_to(admin_orders_path)
        end
      end
    end
  end
end
