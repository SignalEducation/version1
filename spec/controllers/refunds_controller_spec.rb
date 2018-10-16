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

  let(:stripe_management_user_group) { FactoryBot.create(:stripe_management_user_group) }
  let(:stripe_management_user) { FactoryBot.create(:stripe_management_user, user_group_id: stripe_management_user_group.id) }
  let!(:stripe_management_student_access) { FactoryBot.create(:complimentary_student_access, user_id: stripe_management_user.id) }

  let!(:refund_1) { FactoryBot.create(:refund) }
  let!(:refund_2) { FactoryBot.create(:refund) }
  let!(:valid_params) { FactoryBot.attributes_for(:refund) }


  context 'Logged in as a stripe_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
    end

    describe "GET 'show/1'" do
      it 'should see refund_1' do
        get :show, id: refund_1.id
        expect_show_success_with_model('refund', refund_1.id)
      end

      # optional - some other object
      it 'should see refund_2' do
        get :show, id: refund_2.id
        expect_show_success_with_model('refund', refund_2.id)
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
        post :create, refund: valid_params
        expect_create_success_with_model('refund', refunds_url)
      end

      xit 'should report error for invalid params' do
        post :create, refund: {valid_params.keys.first => ''}
        expect_create_error_with_model('refund')
      end
    end

  end

end
