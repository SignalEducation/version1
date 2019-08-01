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

  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:basic_student) { FactoryBot.create(:basic_student, user_group_id: student_user_group.id) }
  let(:stripe_management_user_group) { FactoryBot.create(:stripe_management_user_group) }
  let(:stripe_management_user) { FactoryBot.create(:stripe_management_user, user_group_id: stripe_management_user_group.id) }
  let!(:gbp) { create(:gbp) }
  let!(:uk) { create(:uk, currency: gbp) }
  let!(:uk_vat_code) { create(:vat_code, country: uk) }
  let!(:uk_vat_rate) { create(:vat_rate, vat_code: uk_vat_code) }


  let!(:valid_params) { FactoryBot.attributes_for(:refund, stripe_charge_guid: 'stripe-charge-guid-a') }


  context 'Logged in as a stripe_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
    end

    describe "GET 'show'" do
      xit 'should see refund_1' do
        url = 'https://api.stripe.com/v1/refunds'
        request_body = {"amount"=>"1", "charge"=>"stripe-charge-guid", "reason"=>"requested_by_customer"}
        response_body = {"id": "re_CRvumGmpCr9pF2", "object": "refund", "amount": 1,
                         "reason": "requested_by_customer", "status": "succeeded"}

        stub_refund_create_request(url, request_body, response_body)
        refund_1 = FactoryBot.create(:refund, stripe_charge_guid: 'stripe-charge-guid')

        get :show, params: { id: refund_1.id }
        expect_show_success_with_model('refund', refund_1.id)
      end

    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('refund')
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for valid params' do
        url = 'https://api.stripe.com/v1/refunds'
        request_body = {"amount"=>"1", "charge"=>"stripe-charge-guid-a", "reason"=>"requested_by_customer"}
        response_body = {"id": "re_CRvumGmpCr9pF2", "object": "refund", "amount": 1,
                         "reason": "requested_by_customer", "status": "succeeded"}

        stub_refund_create_request(url, request_body, response_body)

        post :create, params: { refund: valid_params }
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.refunds.create.flash.success'))
        expect(response.status).to eq(302)
        expect(a_request(:post, url).with(body: request_body)).to have_been_made.once
      end

      it 'should report error for invalid params' do
        url = 'https://api.stripe.com/v1/refunds'
        response_body = {"id": "re_CRvumGmpCr9pF2", "object": "refund", "amount": 1,
                         "reason": "requested_by_customer", "status": "succeeded"}

        stub_refund_create_request(url, nil, response_body)

        post :create, params: { refund: {valid_params.keys.first => ''} }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.refunds.create.flash.error'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
        expect(a_request(:post, url).with(body: nil)).to have_been_made.once
      end
    end

  end

end
