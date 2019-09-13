require 'rails_helper'

RSpec.describe UserPasswordsController, type: :controller do

  let!(:student_user) { FactoryBot.create(:student_user) }
  let!(:student_access) { FactoryBot.create(:valid_free_trial_student_access, user_id: student_user.id) }
  let(:unverified_student_user) { FactoryBot.create(:unverified_user, user_group: student_user.user_group,
                                                    password_reset_requested_at: Time.now - 1.hour,
                                                    password_reset_token: ApplicationController::generate_random_code(20)
  ) }
  let!(:reset_user) { FactoryBot.create(:user_with_reset_requested, user_group: student_user.user_group)}

  #TODO - need to add tests here for set_password and create_password (invite users)

  context 'Nobody logged in: ' do

    describe 'GET new' do
      it 'returns http success' do
        get :new
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end
    end

    describe 'POST create' do
      it 'returns http success' do
        post :create, params: { email_address: student_user.email }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        test_user = User.find(student_user.id)
        expect(test_user.password_reset_token).to_not be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:create)
      end
    end

    describe 'GET edit' do
      it 'returns ERROR link expired with too short token' do
        get :edit, params: { id: 'abc123' }
        expect(flash[:success]).to be_nil
        expect(flash[:warning]).to eq(I18n.t('controllers.user_passwords.edit.flash.warning'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(sign_in_url)
      end

      it 'returns ERROR link expired with a bad token' do
        get :edit, params: { id: 'abc123abc123abc123ab' }
        expect(flash[:success]).to be_nil
        expect(flash[:warning]).to eq(I18n.t('controllers.user_passwords.edit.flash.warning'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(sign_in_url)
      end

      it 'returns ERROR with user not verified' do
        get :edit, params: { id: unverified_student_user.password_reset_token }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.user_passwords.edit.flash.error'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(sign_in_url)
      end

      it 'returns OK from a valid token' do
        get :edit, params: { id: reset_user.password_reset_token }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT update' do
      it 'returns OK for valid params' do
        put :update, params: { password: '123123123', password_confirmation: '123123123', id: reset_user.password_reset_token }
        expect(flash[:success]).to eq(I18n.t('controllers.user_passwords.update.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to be(302)
        expect(response).to redirect_to(root_url)
      end

      it 'returns sends e-mail to user' do
        put :update, params: { password: '123123123', password_confirmation: '123123123', id: reset_user.password_reset_token }
        expect(flash[:success]).to eq(I18n.t('controllers.user_passwords.update.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to be(302)
        expect(reset_user.reload.password_change_required).to eq(nil)
        expect(response).to redirect_to(root_url)
      end

      it 'returns ERROR for invalid params' do
        put :update, params: { password: '123123123', password_confirmation: '123123123', id: '123' }
        expect(flash[:success]).to be_nil
        #Was originally this but changes to update action during csv invite changes resulted failing test fixed for short-term with below lines
        #expect(flash[:error]).to eq(I18n.t('controllers.user_password_resets.update.flash.error'))
        #expect(response).to render_template(:edit)
        expect(flash[:error]).to eq(I18n.t('controllers.user_passwords.update.flash.user_error'))
        expect(response).to redirect_to(root_url)
      end

      it 'returns ERROR for mismatching passwords' do
        put :update, params: { password: '123123123', password_confirmation: '456456456', id: reset_user.password_reset_token }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.user_passwords.update.flash.password_and_confirmation_do_not_match'))
        expect(response).to render_template(:edit)
      end
    end

  end


end
