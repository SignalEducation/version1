# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionPaymentCardsController, type: :controller do
  let(:country)            { create(:country) }
  let(:student_user_group) { create(:student_user_group) }
  let(:student_user)       { create(:student_user, user_group: student_user_group) }
  let(:student_access)     { build(:valid_free_trial_student_access, user: student_user) }
  let(:invalid_params)     { attributes_for(:subscription_payment_card) }
  let(:valid_params)       { invalid_params.merge(account_country_id: country.id, user_id: student_user.id) }
  let(:payment_card)       { create(:subscription_payment_card, account_country_id: country.id, user_id: student_user.id) }

  before do
    activate_authlogic
    UserSession.create!(student_user)
  end

  describe "POST 'create'" do
    it 'create a sub payment card and redirect' do
      expect_any_instance_of(SubscriptionPaymentCardsController).to receive(:create_params).and_return(valid_params)
      post :create, params: { subscription_payment_card: valid_params }

      expect(flash[:error]).to eq(nil)
      expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.success'))
      expect(response.status).to eq(302)
      expect(response).to redirect_to(account_url(anchor: 'payment-details'))
    end

    it 'get an error in create a sub payment card and redirect' do
      post :create, params: { subscription_payment_card: invalid_params }

      expect(flash[:success]).to eq(nil)
      expect(flash[:error]).to eq('must exist')
      expect(response.status).to eq(302)
      expect(response).to redirect_to(account_url(anchor: 'add-card-modal'))
    end

    it 'get a new card error in create a sub payment card and redirect' do
      expect_any_instance_of(ActiveModel::Errors).to receive(:any?).and_return(false)
      post :create, params: { subscription_payment_card: invalid_params }

      expect(flash[:success]).to eq(nil)
      expect(flash[:error]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.error'))
      expect(response.status).to eq(302)
      expect(response).to redirect_to(account_url(anchor: 'add-card-modal'))
    end
  end

  describe "PUT 'update'" do
    context 'when valid' do
      it 'redirect after update' do
        expect_any_instance_of(SubscriptionPaymentCard).to receive(:update_as_the_default_card).and_return(true)
        put :update, params: { id: payment_card.id }

        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end
    end

    context 'when invalid' do
      it 'redirect after error in update' do
        expect_any_instance_of(SubscriptionPaymentCard).to receive(:update_as_the_default_card).and_return(false)
        put :update, params: { id: payment_card.id }

        expect(flash[:success]).to eq(nil)
        expect(flash[:error]).to eq(I18n.t('controllers.subscription_payment_cards.update.flash.error'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end
    end
  end

  describe "DELETE 'destroy'" do
    context 'when valid' do
      it 'redirect after update' do
        expect_any_instance_of(SubscriptionPaymentCard).to receive(:destroy).and_return(true)
        delete :destroy, params: { id: payment_card.id }

        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.delete.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end
    end

    context 'when invalid' do
      it 'redirect after error in update' do
        expect_any_instance_of(SubscriptionPaymentCard).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: payment_card.id }

        expect(flash[:success]).to eq(nil)
        expect(flash[:error]).to eq(I18n.t('controllers.subscription_payment_cards.delete.flash.error'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end
    end
  end
end
