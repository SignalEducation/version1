# == Schema Information
#
# Table name: home_pages
#
#  id                            :integer          not null, primary key
#  seo_title                     :string
#  seo_description               :string
#  subscription_plan_category_id :integer
#  public_url                    :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

require 'rails_helper'
require 'support/users_and_groups_setup'
require 'mandrill_client'

describe HomePagesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:home_page_1) { FactoryGirl.create(:home_page) }
  let!(:home_page_2) { FactoryGirl.create(:cfa_home) }
  let!(:home_page_3) { FactoryGirl.create(:home) }
  let!(:valid_params) { FactoryGirl.attributes_for(:home_page) }
  let!(:sign_up_params) { { first_name: "Test", last_name: "Student",
                            locale: 'en',
                            email: "test.student@example.com", password: "dummy_pass",
                            password_confirmation: "dummy_pass" } }
  let!(:default_plan) { FactoryGirl.create(:subscription_plan) }
  let!(:student) { FactoryGirl.create(:individual_student_user) }
  let!(:referral_code) { FactoryGirl.create(:referral_code, user_id: student.id) }

  context 'Not logged in: ' do

    describe "GET 'show/1'" do
      let!(:country) { FactoryGirl.create(:uk) }
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see home_page_1' do
        get :show, id: home_page_3.id
        expect_show_success_with_model('home_page', home_page_3.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'student_sign_up'" do
      describe "invalid data" do

        it 'does not subscribe user if user with same email already exists' do
          request.env['HTTP_REFERER'] = '/'
          post :student_sign_up, user: sign_up_params.merge(email: student.email)
          expect(session[:sign_up_errors].keys).to include(:email)
          expect(response.status).to eq(302)
          expect(response).to redirect_to('/')
        end

        it 'does not subscribe user if password is blank' do
          request.env['HTTP_REFERER'] = '/'
          post :student_sign_up, user: sign_up_params.merge(password: nil)
          expect(session[:sign_up_errors].keys).to include(:password)
          expect(response.status).to eq(302)
          expect(response).to redirect_to('/')
        end

        it 'does not subscribe user if password is not of required length' do
          request.env['HTTP_REFERER'] = '/'
          post :student_sign_up, user: sign_up_params.merge(password: '12345')
          expect(session[:sign_up_errors].keys).to include(:password)
          expect(response.status).to eq(302)
          expect(response).to redirect_to('/')
        end

      end

      describe "valid data" do
        it 'signs up new student' do
          referral_codes = ReferralCode.count
          post :student_sign_up, user: sign_up_params
          expect(response.status).to eq(302)
          expect(response).to redirect_to(personal_sign_up_complete_url)
          expect(ReferralCode.count).to eq(referral_codes + 1)
        end


        xit 'sends verification email to the user' do
          # We do not know in advance what will be user's activation
          # code so we have to capture its value. That's why we are
          # defining these methods on double. This way we are also
          # testing that 'send_verification_email' is called on
          # MandrillClient.
          mc = double
          def mc.send_verification_email(url)
            @url = url
          end
          def mc.url
            return @url
          end

          expect(MandrillClient).to receive(:new).and_return(mc)
          post :student_sign_up, user: sign_up_params
          expect(mc.url).to eq(user_verification_url(email_verification_code: User.last.email_verification_code))
        end

        it 'creates referred signup if user comes from referral link' do
          cookies.encrypted[:referral_data] = "#{referral_code.code};http://referral.example.com"
          post :student_sign_up, user: sign_up_params
          #expect(flash[:success]).to eq(I18n.t('controllers.home_pages.student_sign_up.flash.success'))
          expect(response.status).to eq(302)
          expect(response).to redirect_to(personal_sign_up_complete_url)

          expect(ReferredSignup.count).to eq(1)
          rs = ReferredSignup.first
          expect(rs.referral_code_id).to eq(referral_code.id)
          expect(rs.user_id).to eq(User.last.id)
          expect(rs.referrer_url).to eq("http://referral.example.com")
        end
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'show/1'" do
      it 'should redirect to dashboard' do
        get :show, id: home_page_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
        expect(assigns('home_page'.to_sym).class.name).to eq('home_page'.classify)
        expect(assigns('home_page'.to_sym).id).to eq(home_page_1.id) if home_page_1.id
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'student_sign_up'" do
      it "should redirect to dashboard page" do
        post :student_sign_up, user: sign_up_params
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
      end
    end
  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'show/1'" do
      it 'should redirect to dashboard' do
        get :show, id: home_page_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
        expect(assigns('home_page'.to_sym).class.name).to eq('home_page'.classify)
        expect(assigns('home_page'.to_sym).id).to eq(home_page_1.id) if home_page_1.id
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'student_sign_up'" do
      it "should redirect to dashboard page" do
        post :student_sign_up, user: sign_up_params
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'show/1'" do
      it 'should redirect to dashboard' do
        get :show, id: home_page_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
        expect(assigns('home_page'.to_sym).class.name).to eq('home_page'.classify)
        expect(assigns('home_page'.to_sym).id).to eq(home_page_1.id) if home_page_1.id
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'student_sign_up'" do
      it "should redirect to dashboard page" do
        post :student_sign_up, user: sign_up_params
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'show/1'" do
      it 'should redirect to dashboard' do
        get :show, id: home_page_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
        expect(assigns('home_page'.to_sym).class.name).to eq('home_page'.classify)
        expect(assigns('home_page'.to_sym).id).to eq(home_page_1.id) if home_page_1.id
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'student_sign_up'" do
      it "should redirect to dashboard page" do
        post :student_sign_up, user: sign_up_params
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'show/1'" do
      it 'should redirect to dashboard' do
        get :show, id: home_page_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
        expect(assigns('home_page'.to_sym).class.name).to eq('home_page'.classify)
        expect(assigns('home_page'.to_sym).id).to eq(home_page_1.id) if home_page_1.id
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'student_sign_up'" do
      it "should redirect to dashboard page" do
        post :student_sign_up, user: sign_up_params
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'show/1'" do
      it 'should redirect to dashboard' do
        get :show, id: home_page_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
        expect(assigns('home_page'.to_sym).class.name).to eq('home_page'.classify)
        expect(assigns('home_page'.to_sym).id).to eq(home_page_1.id) if home_page_1.id
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'student_sign_up'" do
      it "should redirect to dashboard page" do
        post :student_sign_up, user: sign_up_params
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'show/1'" do
      it 'should redirect to dashboard' do
        get :show, id: home_page_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
        expect(assigns('home_page'.to_sym).class.name).to eq('home_page'.classify)
        expect(assigns('home_page'.to_sym).id).to eq(home_page_1.id) if home_page_1.id
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'student_sign_up'" do
      it "should redirect to dashboard page" do
        post :student_sign_up, user: sign_up_params
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'show/1'" do
      it 'should redirect to dashboard' do
        get :show, id: home_page_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
        expect(assigns('home_page'.to_sym).class.name).to eq('home_page'.classify)
        expect(assigns('home_page'.to_sym).id).to eq(home_page_1.id) if home_page_1.id
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('home_page')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_edit_success_with_model('home_page', home_page_1.id)
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_edit_success_with_model('home_page', home_page_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_create_success_with_model('home_page', home_pages_url)
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_create_error_with_model('home_page')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_update_success_with_model('home_page', home_pages_url)
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_update_success_with_model('home_page', home_pages_url)
        expect(assigns(:home_page).id).to eq(home_page_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_update_error_with_model('home_page')
        expect(assigns(:home_page).id).to eq(home_page_1.id)
      end
    end

    describe "POST 'student_sign_up'" do
      it "should redirect to dashboard page" do
        post :student_sign_up, user: sign_up_params
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(dashboard_url)
      end
    end

  end

end
