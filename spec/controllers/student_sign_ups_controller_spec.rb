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
  let!(:student_user)   { create(:student_user) }
  let(:gbp)             { create(:gbp) }
  let(:uk)              { create(:uk, currency_id: gbp.id) }
  let!(:uk_vat_code)    { create(:vat_code, country: uk) }
  let!(:subscription_plan_gbp_m) {
    create(:student_subscription_plan_m, currency: gbp, price: 7.50,
           stripe_guid: 'stripe_plan_guid_m', payment_frequency_in_months: 3, exam_body: exam_body_1)
  }

  let(:unverified_user) { create(:student_user, user_group: student_user.user_group, account_activated_at: nil, account_activation_code: '987654321', active: false, email_verified_at: nil, email_verification_code: '123456687', email_verified: false) }
  let!(:sign_up_params) { { first_name: 'Tes', last_name: 'Studen', country_id: uk.id, locale: 'en', email: 'test.student@example.com', password: 'dummy_pas', password_confirmation: 'dummy_pas', email_verification_code: 'c5a8a2cb71d476ff4ed' } }

  context 'Not logged in...' do
    describe "GET 'home'" do
      it 'should see home with home_page record' do
        get :home, params: { public_url: '/' }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:home)
      end

      it 'should see home without home_page record' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:home)
      end
    end

    describe "GET 'landing'" do
      it 'should see landing page' do
        get :landing, params: { public_url: landing_page_1.public_url }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:landing)
      end

      it 'should redirect to root as no home_page record' do
        get :landing, params: { public_url: '' }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    describe "GET 'sign_in_or_register'" do
      it 'should see sign_in_or_register page' do
        get :sign_in_or_register, params: { plan_guid: subscription_plan_gbp_m.guid, exam_body_id: exam_body_1.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:sign_in_or_register)
      end
    end

    describe "GET 'sign_in_checkout'" do
      it 'should see sign_in_checkout page' do
        get :sign_in_checkout, params: { plan_guid: subscription_plan_gbp_m.guid, exam_body_id: exam_body_1.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:sign_in_checkout)
      end
    end

    describe "GET 'group'" do
      it 'should render group page' do
        get :group, params: { name_url: group_1.name_url }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'new'" do
      it 'should render sign up page' do
        get :new
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end
    end

    describe "POST 'create'" do
      # Stripe Customer Create
      describe 'invalid data' do
        it 'does not subscribe user if user with same email already exists' do
          request.env['HTTP_REFERER'] = '/en/student_new'
          post :create, params: { user: sign_up_params.merge(email: student_user.email) }
          expect(response.status).to eq(302)
          expect(response).to redirect_to(request.referer)
        end

        it 'does not subscribe user if password is blank' do
          request.env['HTTP_REFERER'] = '/en/student_new'
          post :create, params: { user: sign_up_params.merge(password: nil) }
          expect(response.status).to eq(302)
          expect(response).to redirect_to(request.referer)
        end

        it 'does not subscribe user if password is not of required length' do
          request.env['HTTP_REFERER'] = '/en/student_new'
          post :create, params: { user: sign_up_params.merge(password: '12345') }
          expect(response.status).to eq(302)
          expect(response).to redirect_to(request.referer)
        end
      end

      describe 'valid data' do
        it 'signs up new student' do
          stripe_url = 'https://api.stripe.com/v1/customers'
          stripe_request_body = { 'email' => 'test.student@example.com' }
          stub_customer_create_request(stripe_url, stripe_request_body)

          # TODO: Mandrill call needs to be stubbed [verification_code issue]
          # mandrill_url = 'https://mandrillapp.com/api/1.0/messages/send-template.json'
          # email= 'test.student@example.com'
          # template = 'email_verification_181015'
          # stub_mandrill_verification_request(mandrill_url)

          user_count = User.all.count
          post :create, params: { user: sign_up_params }
          user = assigns(:user)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(personal_sign_up_complete_url(account_activation_code: user.account_activation_code))
          expect(User.all.count).to eq(user_count + 1)

          # expect(a_request(:post, stripe_url).with(body: stripe_request_body)).to have_been_made.once
        end

        xit 'creates referred signup if user comes from referral link' do
          stripe_url = 'https://api.stripe.com/v1/customers'
          stripe_request_body = { 'email' => 'test.student@example.com' }
          stub_customer_create_request(stripe_url, stripe_request_body)

          cookies.encrypted[:referral_data] = "#{student_user.referral_code.code};http://referral.example.com"
          post :create, params: { user: sign_up_params }
          user = assigns(:user)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(personal_sign_up_complete_url(account_activation_code: user.account_activation_code))
          expect(Subscription.all.count).to eq(0)

          expect(ReferredSignup.count).to eq(1)
          rs = ReferredSignup.first
          expect(rs.referral_code_id).to eq(student_user.referral_code.id)
          expect(rs.user_id).to eq(User.last.id)
          expect(rs.referrer_url).to eq('http://referral.example.com')
        end
      end
    end

    describe "GET 'show'" do
      # This is the post sign-up landing page - personal_sign_up_complete
      it 'returns http success' do
        get :show, params: { account_activation_code: unverified_user.account_activation_code }
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
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
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
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
