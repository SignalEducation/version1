require 'rails_helper'
require 'support/users_and_groups_setup'

describe ReferralCodesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:tutor) { FactoryGirl.create(:tutor_user, user_group_id: tutor_user_group.id ) }
  let!(:tutor_referral_code) { FactoryGirl.create(:referral_code, user_id: tutor.id) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to sign_in' do
        get :show, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create
        expect_bounce_as_not_signed_in
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see own referral code' do
        ref_code = individual_student_user.create_referral_code
        get :show, id: ref_code.id
        expect_show_success_with_model('referral_code', ref_code.id)
      end

      # optional - some other object
      it 'should not see other user referral code' do
        get :show, id: tutor_referral_code.id
        expect_error_bounce(profile_url)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root URL for plain HTML request' do
        post :create
        expect(response).to redirect_to(root_url)
      end

      it 'should report OK for Ajax request' do
        xhr :post, :create
        expect(response.headers['Content-Type']).to include("text/javascript")
        expect(response.status).to eq(200)
        json = JSON.parse(response.body)
        expect(json['code']).to eq(ReferralCode.last.code)
        expect(json['url']).to include(ReferralCode.last.code)
      end

      it 'should report error for Ajax request if student already has referral code' do
        individual_student_user.create_referral_code
        xhr :post, :create
        expect(response.status).to eq(422)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t('controllers.referral_codes.create.flash.error'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        ref_code = individual_student_user.create_referral_code
        delete :destroy, id: ref_code.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see tutor_referral_code' do
        ref_code = tutor_user.create_referral_code
        get :show, id: ref_code.id
        expect_show_success_with_model('referral_code', ref_code.id)
      end

      # optional - some other object
      it 'should not see other user referral code' do
        get :show, id: tutor_referral_code.id
        expect_error_bounce(profile_url)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root URL for plain HTML request' do
        post :create
        expect(response).to redirect_to(root_url)
      end

      it 'should report OK for Ajax request' do
        xhr :post, :create
        expect(response.headers['Content-Type']).to include("text/javascript")
        expect(response.status).to eq(200)
        json = JSON.parse(response.body)
        expect(json['code']).to eq(ReferralCode.last.code)
        expect(json['url']).to include(ReferralCode.last.code)
      end

      it 'should report error for Ajax request if student already has referral code' do
        tutor_user.create_referral_code
        xhr :post, :create
        expect(response.status).to eq(422)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t('controllers.referral_codes.create.flash.error'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see own referral code' do
        ref_code = corporate_student_user.create_referral_code
        get :show, id: ref_code.id
        expect_show_success_with_model('referral_code', ref_code.id)
      end

      # optional - some other object
      it 'should not see other user referral code' do
        get :show, id: tutor_referral_code.id
        expect_error_bounce(profile_url)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root URL for plain HTML request' do
        post :create
        expect(response).to redirect_to(root_url)
      end

      it 'should report OK for Ajax request' do
        xhr :post, :create
        expect(response.headers['Content-Type']).to include("text/javascript")
        expect(response.status).to eq(200)
        json = JSON.parse(response.body)
        expect(json['code']).to eq(ReferralCode.last.code)
        expect(json['url']).to include(ReferralCode.last.code)
      end

      it 'should report error for Ajax request if student already has referral code' do
        corporate_student_user.create_referral_code
        xhr :post, :create
        expect(response.status).to eq(422)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq(I18n.t('controllers.referral_codes.create.flash.error'))
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create
        expect_bounce_as_not_allowed
      end

      it 'should bounce as not allowed' do
        post :create
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create
        expect_bounce_as_not_allowed
      end

      it 'should bounce as not allowed' do
        post :create
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create
        expect_bounce_as_not_allowed
      end

      it 'should bounce as not allowed' do
        post :create
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create
        expect_bounce_as_not_allowed
      end

      it 'should bounce as not allowed' do
        post :create
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('referral_codes', 1)
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: tutor_referral_code.id
        expect_error_bounce(referral_codes_url)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root URL for pain HTML request' do
        post :create
        expect(response).to redirect_to(root_url)
      end

      it 'should return Unprocessible entity (422) with appropriate message' do
        xhr :post, :create
        expect(response.headers['Content-Type']).to include("text/javascript")
        expect(response.status).to eq(422)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        individual_student_user = FactoryGirl.create(:individual_student_user)
        individual_student_user.update_attribute(:referral_code_id, tutor_referral_code.id)
        delete :destroy, id: tutor_referral_code.id
        expect_delete_error_with_model('referral_code', referral_codes_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor_referral_code.id
        expect_delete_success_with_model('referral_code', referral_codes_url)
      end
    end

  end

end
