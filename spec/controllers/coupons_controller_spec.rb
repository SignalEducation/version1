# == Schema Information
#
# Table name: coupons
#
#  id                 :integer          not null, primary key
#  name               :string
#  code               :string
#  currency_id        :integer
#  livemode           :boolean          default(FALSE)
#  active             :boolean          default(FALSE)
#  amount_off         :integer
#  duration           :string
#  duration_in_months :integer
#  max_redemptions    :integer
#  percent_off        :integer
#  redeem_by          :datetime
#  times_redeemed     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_coupon_data :text
#

require 'rails_helper'

describe CouponsController, type: :controller do

  let(:stripe_management_user_group) { FactoryBot.create(:stripe_management_user_group) }
  let(:stripe_management_user) { FactoryBot.create(:stripe_management_user,
                                                   user_group_id: stripe_management_user_group.id) }
  let!(:stripe_management_student_access) { FactoryBot.create(:complimentary_student_access,
                                                              user_id: stripe_management_user.id) }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:student_user) { FactoryBot.create(:student_user, user_group_id: student_user_group.id) }
  let!(:student_access) { FactoryBot.create(:valid_free_trial_student_access, user_id: student_user.id) }

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }
  let!(:plan1) { FactoryBot.create(:student_subscription_plan_m,
                                                     currency_id: gbp.id, price: 65.50) }

  let!(:coupon_1) { FactoryBot.create(:coupon) }
  let!(:coupon_2) { FactoryBot.create(:coupon) }
  let!(:valid_params) { FactoryBot.attributes_for(:coupon) }


  context 'Logged in as a stripe_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('coupons', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see coupon_1' do
        get :show, id: coupon_1.id
        expect_show_success_with_model('coupon', coupon_1.id)
      end

      # optional - some other object
      it 'should see coupon_2' do
        get :show, id: coupon_2.id
        expect_show_success_with_model('coupon', coupon_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('coupon')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, coupon: valid_params
        expect_create_success_with_model('coupon', coupons_url)
      end

      it 'should report error for invalid params' do
        post :create, coupon: {valid_params.keys.first => ''}
        expect_create_error_with_model('coupon')
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: coupon_2.id
        expect_delete_success_with_model('coupon', coupons_url)
      end
    end

    describe "POST 'validate_coupon'" do
      it 'should be OK as valid code' do
        post :validate_coupon, { coupon_code: coupon_1.code, plan_id: plan1.id, format: :json }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).first[1]).to eq(true)
      end

      it 'should be ERROR as invalid code' do
        post :validate_coupon, { coupon_code: 'abc123', plan_id: plan1.id, format: :json }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).first[1]).to eq(false)

      end
    end

  end

  context 'Logged in as a student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "POST 'validate_coupon'" do
      it 'should be OK as valid code' do
        post :validate_coupon, { coupon_code: coupon_1.code, plan_id: plan1.id, format: :json }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).first[1]).to eq(true)
      end

      it 'should be ERROR as invalid code' do
        post :validate_coupon, { coupon_code: 'abc123', plan_id: plan1.id, format: :json }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).first[1]).to eq(false)

      end
    end
  end

end
