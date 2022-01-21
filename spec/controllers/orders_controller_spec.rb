# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  course_id         :integer
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
  let!(:exam_body_1)         { create(:exam_body) }
  let!(:group_1)             { create(:group, exam_body: exam_body_1) }
  let(:gbp)                        { create(:gbp) }
  let!(:uk)                  { create(:uk, currency: gbp) }
  let!(:uk_vat_code)         { create(:vat_code, country: uk) }

  let!(:student_user_group)  { create(:student_user_group) }
  let!(:basic_student)       { create(:basic_student, user_group: student_user_group, preferred_exam_body_id: exam_body_1.id, currency: gbp) }

  let!(:mock_exam_1)         { create(:mock_exam) }
  let!(:product_1)           { create(:product, currency_id: gbp.id, mock_exam_id: mock_exam_1.id, price: '99.9') }
  let!(:product_2)           { create(:product, currency_id: gbp.id) }
  let!(:product_3)           { create(:lifetime_product, currency_id: gbp.id, group: group_1) }
  let!(:valid_params)        { attributes_for(:order, product_id: product_1.id, stripe_payment_method_id: 'pi_afsdafdfafsd') }
  let(:order_1)              { create(:order, product_id: product_1.id,
                                      stripe_customer_id: 'cus_fadsfdsf',
                                      stripe_payment_method_id: 'pm_dsafdsfdsfdf',
                                      stripe_payment_intent_id: 'pi_dsafdsfdsfdf',
                                      stripe_order_payment_data: { currency: gbp.iso_code },
                                                                   stripe_status: 'paid') }
  let(:order_2)              { create(:order, stripe_order_payment_data: { currency: gbp.iso_code }) }
  let(:order_3)              { create(:order, product_id: product_3.id, stripe_order_payment_data: { currency: gbp.iso_code }) }

  context 'Logged in as a valid_subscription_student: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(basic_student)
    end

    describe "GET 'new'" do
      it 'should respond OK with product id' do
        get :new, params: { product_id: product_1.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end

      it 'should respond OK with exam_body id' do
        get :new, params: { exam_body_id: exam_body_1.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end
    end

    describe "POST 'create'" do
      before :each do
        allow_any_instance_of(PurchaseService).to receive(:create_purchase).and_return(order_1)
      end

      it 'should report OK for valid params' do
        post :create, params: { product_id: product_1.id, order: valid_params }, format: :json
        expect(response.status).to eq 200
        expect(response.body).not_to be_nil
      end

      it 'should report error for invalid params' do
        post :create, params: { product_id: product_1.id, order: { valid_params.keys.first => '' } }
        expect(flash[:error]).not_to be_nil
      end

      it 'should not create a order' do
        allow_any_instance_of(Order).to receive(:save).and_return(false)
        post :create, params: { product_id: product_1.id, order: { valid_params.keys.first => '' } }

        expect(flash[:error]).not_to be_nil
      end
    end

    describe "POST 'update'" do
      before :each do
        allow_any_instance_of(Order).to receive(:stripe?).and_return(true)
        allow_any_instance_of(Order).to receive(:pending_3d_secure?).and_return(true)
        allow(Stripe::PaymentIntent).to receive(:confirm).and_return(double(status: 'succeeded'))
        allow_any_instance_of(PurchaseService).to receive(:create_purchase).and_return(order_1)
        order_1.mark_payment_action_required
      end

      it 'should report OK for valid params' do
        patch :update, params: { id: order_1.id, status: 'requires_confirmation' }, format: :json

        expect(order_1.reload.state).to eq('completed')
      end

      it 'should not update a order' do
        allow_any_instance_of(Order).to receive(:stripe?).and_return(false)
        allow_any_instance_of(Order).to receive(:pending_3d_secure?).and_return(false)
        patch :update, params: { id: order_2.id, status: 'requires_confirmation' }, format: :json

        expect(order_2.reload.state).to eq('pending')
      end

      it 'should not update a order' do
        patch :update, params: { id: order_1.id, status: 'succeeded' }, format: :json

        expect(order_1.reload.state).to eq('completed')
      end

      it 'should not update a order' do
        patch :update, params: { id: order_1.id, status: 'no_case' }, format: :json

        expect(order_1.reload.state).to eq('pending')
      end
    end

    describe "GET 'execute'" do
      before { allow_any_instance_of(PaypalService).to receive(:execute_payment).and_return(true) }

      it 'should redirect to user exercises an error' do
        get :execute, params: { id: order_1.id, payment_processor: 'paypal' }

        expect(flash[:success]).not_to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_exercises_path(basic_student))
      end

      it 'should redirect to user exercises an error' do
        get :execute, params: { id: order_1.id, payment_processor: 'paypal' }

        expect(flash[:success]).not_to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(user_exercises_path(basic_student))
      end

      it 'should redirect to order complete' do
        get :execute, params: { id: order_3.id, payment_processor: 'paypal' }

        expect(flash[:success]).not_to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(order_complete_url(product_id: order_3.product_id,
                                                           product_type: order_3.product.url_by_type,
                                                           order_id: order_3.id,
                                                           payment_processor: 'Paypal'))
      end

      it 'should return an error' do
        get :execute, params: { id: order_1.id }

        expect(flash[:success]).to be_nil
        expect(flash[:error]).not_to be_nil
        expect(response.status).to eq(302)
      end
    end

    describe "GET 'order_complete'" do
      it 'should respond OK' do
        get :order_complete, params: { order_id: order_3.id, product_id: product_1.id, product_type: product_1.url_by_type, }

        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:order_complete)
      end
    end
  end
end
