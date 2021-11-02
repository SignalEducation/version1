# frozen_string_literal: true

require 'rails_helper'
require 'support/mandrill_web_mock_helpers'

RSpec.describe StudentSignUpsController, type: :controller do
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  let!(:exam_body_1)    { create(:exam_body) }
  let!(:group_1)        { create(:group) }
  let!(:group_2)        { create(:group) }
  let!(:course_1)       { create(:active_course, group_id: group_1.id, exam_body_id: exam_body_1.id) }
  let!(:home)           { create(:home, group_id: group_1.id) }
  let!(:landing_page_1) { create(:landing_page_1, group_id: group_1.id) }
  let!(:landing_page_2) { create(:landing_page_2, course_id: course_1.id, group_id: nil) }
  let!(:landing_page_3) { create(:landing_page_3, course_id: course_1.id, group_id: group_1.id) }
  let!(:student_user)   { create(:student_user) }
  let(:gbp)             { create(:gbp) }
  let(:uk)              { create(:uk, currency_id: gbp.id) }
  let!(:uk_vat_code)    { create(:vat_code, country: uk) }
  let!(:subscription_plan_gbp_m) {
    create(:student_subscription_plan_m, currency: gbp, price: 7.50,
           stripe_guid: 'stripe_plan_guid_m', payment_frequency_in_months: 3, exam_body: exam_body_1)
  }

  let(:unverified_user) { create(:student_user, user_group: student_user.user_group, account_activated_at: nil, account_activation_code: '987654321', active: false, email_verified_at: nil, email_verification_code: '123456687', email_verified: false, preferred_exam_body_id: exam_body_1.id, terms_and_conditions: true) }
  let!(:sign_up_params) { { first_name: 'Test', last_name: 'Student', country_id: uk.id, locale: 'en', email: 'test.student@example.com', password: 'dummy_pas', password_confirmation: 'dummy_pas', email_verification_code: 'c5a8a2cb71d476ff4ed', preferred_exam_body_id: exam_body_1.id, terms_and_conditions: true } }

  context 'Logged in as a student_user' do
    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home, params: { public_url: '/' }
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "GET 'landing'" do
      it 'should see landing page' do
        get :landing, params: { public_url: landing_page_1.public_url }
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:landing)
      end
    end

    describe "GET 'new_landing'" do
      it 'should see new_landing page' do
        get :new_landing, params: { public_url: landing_page_3.public_url }
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new_landing)
      end
    end

    describe "GET 'sign_in_or_register'" do
      it 'should see sign_in_or_register page' do
        get :sign_in_or_register, params: { plan_guid: subscription_plan_gbp_m.guid, exam_body_id: exam_body_1.id }
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "GET 'sign_in_checkout'" do
      it 'should see sign_in_checkout page' do
        get :sign_in_checkout, params: { plan_guid: subscription_plan_gbp_m.guid, exam_body_id: exam_body_1.id }
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "GET 'show'" do
      it 'should bounce as signed in' do
        get :show, params: { account_activation_code: unverified_user.account_activation_code }
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end

    describe "GET 'new'" do
      it 'should bounce as signed in' do
        get :new
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "POST 'create'" do
      it 'should bounce as signed in' do
        post :create, params: { user: sign_up_params }
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "GET 'pricing'" do
      # This is the post sign-up landing page - personal_sign_up_complete
      it 'returns http success' do
        get :pricing
        expect(response.status).to eq(200)
        expect(response).to render_template(:pricing)
      end

      it '/group returns http success' do
        get :pricing, params: { group_name_url: group_1.name_url }
        expect(response.status).to eq(200)
        expect(response).to render_template(:pricing)
      end
    end

  end
end
