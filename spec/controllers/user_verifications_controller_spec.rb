require 'rails_helper'
require 'authlogic/test_case'

RSpec.describe UserVerificationsController, :type => :controller do

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let(:unverified_student_user) { FactoryBot.create(:unverified_user, user_group_id: student_user_group.id) }
  let!(:unverified_trial_student_access) { FactoryBot.create(:unverified_trial_student_access, user_id: unverified_student_user.id) }

  #TODO - attention needed here
  context 'Non-verified user' do
    describe "Get 'update'" do
      it 'returns success when given a valid code' do
        get :update, email_verification_code: unverified_student_user.email_verification_code
        expect(controller.params[:email_verification_code]).to eq(unverified_student_user.email_verification_code)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_verified_path)
        expect(flash[:error]).to be_nil
      end

      it 'returns error when given an invalid code' do
        get :update, email_verification_code: 'XYZ123'
        expect(response.status).to eq(302)
        expect(flash[:success]).to be_nil
        expect(flash[:warning]).to eq('Sorry! That link has expired. Please try to sign in or contact us for assistance')
      end
    end

    describe "Get 'account_verified'" do
      before(:each) do
        activate_authlogic
        UserSession.create!(unverified_student_user)
      end

      it 'returns success when given a valid code' do
        get :account_verified
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_verified)
        expect(flash[:error]).to be_nil
      end
    end

    describe "Post 'resend_verification_mail'" do
      it 'returns success when given a valid code' do
        request.env['HTTP_REFERER'] = 'http://test.host/en/account_verified'
        post :resend_verification_mail, email_verification_code: unverified_student_user.email_verification_code
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_verified_path)
        expect(flash[:error]).to be_nil
      end
    end
  end

end
