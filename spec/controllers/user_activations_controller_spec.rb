require 'rails_helper'
require 'authlogic/test_case'
require 'support/users_and_groups_setup'

RSpec.describe UserActivationsController, :type => :controller do

  include_context 'users_and_groups_setup'

  let!(:new_user) { FactoryGirl.create(:inactive_individual_student_user) }

  context 'Nobody logged in...' do
    describe "Get 'update'" do
      it 'returns success when given a valid code' do
        get :update, activation_code: new_user.account_activation_code
        expect(controller.params[:activation_code]).to eq(new_user.account_activation_code)
        expect(response.status).to eq(302)
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.user_activations.update.success'))
      end

      it 'returns error when given an invalid code' do
        get :update, activation_code: 'XYZ123'
        expect(response.status).to eq(302)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.user_activations.update.error'))
      end
    end
  end

  context 'Normal user logged in...' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    render_views

    describe "GET 'update'" do
      it 'should result in error despite valid code' do
        get :update, activation_code: new_user.account_activation_code
        expect(response.status).to eq(302)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.application.logged_out_required.flash_error'))
      end
    end
  end

end
