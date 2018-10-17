require 'rails_helper'
require 'support/stripe_web_mock_helpers'
require 'support/mandrill_web_mock_helpers'

RSpec.describe StudentSignUpsController, type: :controller do


  let!(:group_1) { FactoryBot.create(:group) }
  let!(:group_2) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course, group_id: group_1.id, exam_body_id: 1) }

  let!(:home) { FactoryBot.create(:home, group_id: group_1.id) }
  let!(:landing_page_1) { FactoryBot.create(:landing_page_1, group_id: group_1.id) }
  let!(:landing_page_2) { FactoryBot.create(:landing_page_2, subject_course_id: subject_course_1.id, group_id: nil) }

  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:student_user) { FactoryBot.create(:student_user, user_group_id: student_user_group.id) }
  let!(:student_access) { FactoryBot.create(:valid_free_trial_student_access, user_id: student_user.id) }
  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }

  let!(:unverified_user) { FactoryBot.create(:student_user, account_activated_at: nil, account_activation_code: '987654321', active: false, email_verified_at: nil, email_verification_code: '123456687', email_verified: false) }
  let!(:valid_params) { FactoryBot.attributes_for(:student_user, user_group_id: student_user_group.id) }

  let!(:sign_up_params) { { first_name: "Test", last_name: "Student", country_id: uk.id, locale: 'en', email: 'test.student@example.com', password: "dummy_pass", password_confirmation: "dummy_pass" , email_verification_code: "c5a8a2cb71d476ff4ed5" } }


  context 'Not logged in...' do

    describe "GET 'home'" do
      it 'should see home' do
        get :home, public_url: '/'
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:home)
      end
    end

    describe "GET 'landing'" do
      it 'should see landing page' do
        get :landing, public_url: landing_page_1.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:landing)
      end
    end

    describe "GET 'show'" do
      #This is the post sign-up landing page - personal_sign_up_complete
      it 'returns http success' do
        get :show, account_activation_code: unverified_user.account_activation_code
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end

      it 'redirect to sign in as no user found' do
        get :show, account_activation_code: '123abc'
        expect(response.status).to eq(302)
        expect(response).to redirect_to(sign_in_url)
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
      #Stripe Customer Create
      describe "invalid data" do

        it 'does not subscribe user if user with same email already exists' do
          request.env['HTTP_REFERER'] = '/en/student_new'
          post :create, user: sign_up_params.merge(email: student_user.email)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(:new_student)
        end

        it 'does not subscribe user if password is blank' do
          request.env['HTTP_REFERER'] = '/en/student_new'
          post :create, user: sign_up_params.merge(password: nil)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(:new_student)
        end

        it 'does not subscribe user if password is not of required length' do
          request.env['HTTP_REFERER'] = '/en/student_new'
          post :create, user: sign_up_params.merge(password: '12345')
          expect(response.status).to eq(302)
          expect(response).to redirect_to(:new_student)
        end

      end

      describe "valid data" do

        it 'signs up new student' do
          stripe_url = 'https://api.stripe.com/v1/customers'
          stripe_request_body = {'email'=>'test.student@example.com'}
          stub_customer_create_request(stripe_url, stripe_request_body)

          #TODO - Mandrill call needs to be stubbed [verification_code issue]
          #mandrill_url = 'https://mandrillapp.com/api/1.0/messages/send-template.json'
          #email= 'test.student@example.com'
          #template = 'email_verification_181015'
          #stub_mandrill_verification_request(mandrill_url)

          user_count = User.all.count
          post :create, user: sign_up_params
          user = assigns(:user)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(personal_sign_up_complete_url(account_activation_code: user.account_activation_code))
          expect(User.all.count).to eq(user_count + 1)

          expect(a_request(:post, stripe_url).with(body: stripe_request_body)).to have_been_made.once

        end

        it 'creates referred signup if user comes from referral link' do
          stripe_url = 'https://api.stripe.com/v1/customers'
          stripe_request_body = {'email'=>'test.student@example.com'}
          stub_customer_create_request(stripe_url, stripe_request_body)

          cookies.encrypted[:referral_data] = "#{student_user.referral_code.code};http://referral.example.com"
          post :create, user: sign_up_params
          user = assigns(:user)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(personal_sign_up_complete_url(account_activation_code: user.account_activation_code))
          expect(Subscription.all.count).to eq(0)

          expect(ReferredSignup.count).to eq(1)
          rs = ReferredSignup.first
          expect(rs.referral_code_id).to eq(student_user.referral_code.id)
          expect(rs.user_id).to eq(User.last.id)
          expect(rs.referrer_url).to eq("http://referral.example.com")
        end
      end
    end

    describe "POST 'subscribe'" do
      #Mailchimp list
      describe "invalid data" do

        it 'does not subscribe user if data is missing' do
          request.env['HTTP_REFERER'] = '/en/student_new'
          post :create, user: sign_up_params.merge(password: nil)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(:new_student)
        end

      end

      describe "valid data" do

        xit 'subscribes with full data set' do

          user_count = User.all.count
          post :create, user: sign_up_params
          user = assigns(:user)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(personal_sign_up_complete_url(account_activation_code: user.account_activation_code))
          expect(User.all.count).to eq(user_count + 1)

        end

        xit 'subscribes with reduced data set' do
          post :create, user: sign_up_params
          user = assigns(:user)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(personal_sign_up_complete_url(account_activation_code: user.account_activation_code))
          expect(Subscription.all.count).to eq(0)

        end
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
        get :home, public_url: '/'
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "GET 'landing'" do
      it 'should see landing page' do
        get :landing, public_url: landing_page_1.public_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:landing)
      end
    end

    describe "GET 'show'" do
      it 'should bounce as signed in' do
        get :show, account_activation_code: unverified_user.account_activation_code
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
        post :create, user: sign_up_params
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end

    end

  end

end
