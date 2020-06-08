# == Schema Information
#
# Table name: refunds
#
#  id                 :integer          not null, primary key
#  stripe_guid        :string
#  charge_id          :integer
#  stripe_charge_guid :string
#  invoice_id         :integer
#  subscription_id    :integer
#  user_id            :integer
#  manager_id         :integer
#  amount             :integer
#  reason             :text
#  status             :string
#  livemode           :boolean          default(TRUE)
#  stripe_refund_data :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

describe RefundsController, type: :controller do
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end
  let(:refund)                       { build(:refund) }
  let!(:student_user_group )         { create(:student_user_group ) }
  let!(:basic_student)               { create(:basic_student, user_group_id: student_user_group.id) }
  let(:stripe_management_user_group) { create(:stripe_management_user_group) }
  let(:stripe_management_user)       { create(:stripe_management_user, user_group_id: stripe_management_user_group.id) }
  let!(:gbp)                         { create(:gbp) }
  let!(:uk)                          { create(:uk, currency: gbp) }
  let!(:uk_vat_code)                 { create(:vat_code, country: uk) }
  let!(:uk_vat_rate)                 { create(:vat_rate, vat_code: uk_vat_code) }
  let!(:valid_params)                { attributes_for(:refund, stripe_charge_guid: 'stripe-charge-guid-a', user_id: basic_student.id, charge_id: 1, invoice_id: 1, subscription_id: 1, manager_id: 1) }

  context 'Logged in as a stripe_management_user: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
      allow_any_instance_of(StripeApiEvent).to receive(:sync_data_from_stripe).and_return(true)
      allow_any_instance_of(Refund).to receive(:create_on_stripe).and_return(true)
      allow(Refund).to receive(:find).and_return(refund)
    end

    describe "GET 'show'" do
      it 'should see refund' do
        allow(refund).to receive(:id).and_return(1)

        get :show, params: { id: 1 }
        expect_show_success_with_model('refund', refund.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('refund')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { refund: build(:refund).attributes }

        expect(flash[:error]).to be_nil
        expect(flash[:notice]).to eq(I18n.t('controllers.refunds.create.flash.success'))
        expect(response.status).to eq(302)
      end

      it 'should report error for invalid params' do
        post :create, params: { refund: attributes_for(:refund, user_id: basic_student.id) }

        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.refunds.create.flash.error'))
        expect(response.status).to eq(302)
      end
    end
  end
end
