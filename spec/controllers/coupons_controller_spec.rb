
require 'rails_helper'

describe CouponsController, type: :controller do

  let(:stripe_management_user_group) { FactoryBot.create(:stripe_management_user_group) }
  let(:system_requirements_user) { FactoryBot.create(:system_requirements_user, user_group_id: stripe_management_user_group.id) }

  let!(:coupon_1) { FactoryBot.create(:coupon, active: true) }
  let!(:coupon_2) { FactoryBot.create(:coupon) }
  let!(:coupon_2) { FactoryBot.create(:coupon) }
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:gbp) { create(:gbp) }
  let!(:uk) { create(:uk, currency: gbp) }
  let!(:uk_vat_code) { create(:vat_code, country: uk) }
  let!(:subscription_plan_gbp_m) {
    create(
        :student_subscription_plan_m,
        currency: gbp, price: 7.50, stripe_guid: 'stripe_plan_guid_m',
        payment_frequency_in_months: 3,
        exam_body: exam_body_1
    )
  }

  let!(:valid_params) { FactoryBot.attributes_for(:coupon) }


  context 'Logged in as a system_requirements_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(system_requirements_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('coupons', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see coupon_1' do
        get :show, params: { id: coupon_1.id }
        expect_show_success_with_model('coupon', coupon_1.id)
      end

      # optional - some other object
      it 'should see coupon_2' do
        get :show, params: { id: coupon_2.id }
        expect_show_success_with_model('coupon', coupon_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('coupon')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { coupon: valid_params }
        expect_create_success_with_model('coupon', coupons_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { coupon: { valid_params.keys.first => '' } }
        expect_create_error_with_model('coupon')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, params: { id: coupon_1.id }
        expect_delete_success_with_model('coupon', coupons_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: coupon_2.id }
        expect_delete_success_with_model('coupon', coupons_url)
      end
    end

    describe "Post to 'validate_coupon'" do
      it 'should OK for valid coupon' do
        post :validate_coupon, params: { code: coupon_1.code, plan_id: subscription_plan_gbp_m.id }, format: :json
        expect(response.status).to eq(200)
      end
    end

  end

  context 'Not logged in...' do

    describe "GET 'show/1'" do
      it 'should see content_page_1' do
        get :show, params: { id: coupon_1.id }
        expect_bounce_as_not_signed_in
      end
    end
  end

end