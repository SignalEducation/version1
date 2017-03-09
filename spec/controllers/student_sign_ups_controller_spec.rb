require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe StudentSignUpsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:country_1) { FactoryGirl.create(:uk) }
  let!(:country_2) { FactoryGirl.create(:ireland) }
  let!(:country_3) { FactoryGirl.create(:usa) }
  let!(:unverified_user) { FactoryGirl.create(:individual_student_user, account_activated_at: nil, account_activation_code: '987654321', active: false, email_verified_at: nil, email_verification_code: '123456687', email_verified: false) }
  let!(:valid_params) { FactoryGirl.attributes_for(:individual_student_user, user_group_id: individual_student_user_group.id) }

  let!(:sign_up_params) { { first_name: "Test", last_name: "Student", country_id: Country.first.id, locale: 'en', email: "test.student@example.com", password: "dummy_pass", password_confirmation: "dummy_pass" } }
  let!(:student) { FactoryGirl.create(:individual_student_user) }
  let!(:currency) { FactoryGirl.create(:usd) }
  let!(:currency_2) { FactoryGirl.create(:gbp) }
  let!(:referral_code) { FactoryGirl.create(:referral_code, user_id: student.id) }


  context 'Not logged in...' do

    describe "GET 'show'" do
      it 'returns http success' do
        get :show, account_activation_code: unverified_user.account_activation_code
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end

    describe "GET 'account_verified'" do
      it 'should bounce as not signed in' do
        get :account_verified
        expect_bounce_as_not_signed_in
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

      describe "invalid data" do

        it 'does not subscribe user if user with same email already exists' do
          request.env['HTTP_REFERER'] = '/en/student_new'
          post :create, user: sign_up_params.merge(email: student.email)
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
          user_count = User.all.count
          post :create, user: sign_up_params
          user = assigns(:user)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(personal_sign_up_complete_url(account_activation_code: user.account_activation_code))
          expect(User.all.count).to eq(user_count + 1)
        end

        it 'creates referred signup if user comes from referral link' do
          cookies.encrypted[:referral_data] = "#{referral_code.code};http://referral.example.com"
          post :create, user: sign_up_params
          user = assigns(:user)
          expect(response.status).to eq(302)
          expect(response).to redirect_to(personal_sign_up_complete_url(account_activation_code: user.account_activation_code))
          expect(Subscription.all.count).to eq(0)

          expect(ReferredSignup.count).to eq(1)
          rs = ReferredSignup.first
          expect(rs.referral_code_id).to eq(referral_code.id)
          expect(rs.user_id).to eq(User.last.id)
          expect(rs.referrer_url).to eq("http://referral.example.com")
        end
      end
    end

  end

  context 'Logged in as a individual_student_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'show'" do
      it 'should bounce as signed in' do
        get :show, account_activation_code: unverified_user.account_activation_code
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'account_verified'" do
      it 'returns http success' do
        get :account_verified, email_verification_code: student.email_verification_code
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_verified)
      end
    end

    describe "GET 'new'" do
      it 'should bounce as signed in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should bounce as signed in' do
        post :create, user: sign_up_params
        expect_bounce_as_signed_in
      end

    end

  end

  context 'Logged in as a comp_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'show'" do
      it 'should bounce as signed in' do
        get :show, account_activation_code: unverified_user.account_activation_code
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'account_verified'" do
      it 'returns http success' do
        get :account_verified, email_verification_code: student.email_verification_code
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_verified)
      end
    end

    describe "GET 'new'" do
      it 'should bounce as signed in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should bounce as signed in' do
        post :create, user: sign_up_params
        expect_bounce_as_signed_in
      end

    end

  end

  context 'Logged in as a tutor_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'show'" do
      it 'should bounce as signed in' do
        get :show, account_activation_code: unverified_user.account_activation_code
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'account_verified'" do
      it 'returns http success' do
        get :account_verified, email_verification_code: student.email_verification_code
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_verified)
      end
    end

    describe "GET 'new'" do
      it 'should bounce as signed in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should bounce as signed in' do
        post :create, user: sign_up_params
        expect_bounce_as_signed_in
      end

    end

  end

  context 'Logged in as a blogger_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'show'" do
      it 'should bounce as signed in' do
        get :show, account_activation_code: unverified_user.account_activation_code
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'account_verified'" do
      it 'returns http success' do
        get :account_verified, email_verification_code: student.email_verification_code
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_verified)
      end
    end

    describe "GET 'new'" do
      it 'should bounce as signed in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should bounce as signed in' do
        post :create, user: sign_up_params
        expect_bounce_as_signed_in
      end

    end

  end

  context 'Logged in as a content_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'show'" do
      it 'should bounce as signed in' do
        get :show, account_activation_code: unverified_user.account_activation_code
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'account_verified'" do
      it 'returns http success' do
        get :account_verified, email_verification_code: student.email_verification_code
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_verified)
      end
    end

    describe "GET 'new'" do
      it 'should bounce as signed in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should bounce as signed in' do
        post :create, user: sign_up_params
        expect_bounce_as_signed_in
      end

    end

  end

  context 'Logged in as a marketing_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'show'" do
      it 'should bounce as signed in' do
        get :show, account_activation_code: unverified_user.account_activation_code
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'account_verified'" do
      it 'returns http success' do
        get :account_verified, email_verification_code: student.email_verification_code
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_verified)
      end
    end

    describe "GET 'new'" do
      it 'should bounce as signed in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should bounce as signed in' do
        post :create, user: sign_up_params
        expect_bounce_as_signed_in
      end

    end

  end

  context 'Logged in as a customer_support_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'show'" do
      it 'should bounce as signed in' do
        get :show, account_activation_code: unverified_user.account_activation_code
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'account_verified'" do
      it 'returns http success' do
        get :account_verified, email_verification_code: student.email_verification_code
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_verified)
      end
    end

    describe "GET 'new'" do
      it 'should bounce as signed in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should bounce as signed in' do
        post :create, user: sign_up_params
        expect_bounce_as_signed_in
      end

    end

  end

  context 'Logged in as a admin_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'show'" do
      it 'should bounce as signed in' do
        get :show, account_activation_code: unverified_user.account_activation_code
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'account_verified'" do
      it 'returns http success' do
        get :account_verified, email_verification_code: student.email_verification_code
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_verified)
      end
    end

    describe "GET 'new'" do
      it 'should bounce as signed in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should bounce as signed in' do
        post :create, user: sign_up_params
        expect_bounce_as_signed_in
      end

    end

  end

end
