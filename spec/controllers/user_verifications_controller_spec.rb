require 'rails_helper'
require 'authlogic/test_case'
require 'support/users_and_groups_setup'

RSpec.describe UserVerificationsController, :type => :controller do

  include_context 'users_and_groups_setup'


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
        expect(flash[:error]).to eq(I18n.t('controllers.user_activations.update.error'))
      end
    end
  end

end
