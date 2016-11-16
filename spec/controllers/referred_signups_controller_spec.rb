# == Schema Information
#
# Table name: referred_signups
#
#  id               :integer          not null, primary key
#  referral_code_id :integer
#  user_id          :integer
#  referrer_url     :string(2048)
#  subscription_id  :integer
#  maturing_on      :datetime
#  payed_at         :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe ReferredSignupsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:tutor) { FactoryGirl.create(:tutor_user, user_group_id: tutor_user_group.id ) }
  let!(:tutor_referral_code) { FactoryGirl.create(:referral_code, user_id: tutor.id) }
  let!(:referred_student) { FactoryGirl.create(:individual_student_user) }
  let!(:subscription) { FactoryGirl.create(:subscription, user_id: referred_student.id) }
  let!(:referred_signup) { FactoryGirl.create(:referred_signup,
                                              user_id: referred_student.id,
                                              subscription_id: subscription.id,
                                              referral_code_id: tutor_referral_code.id) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update'" do
      it 'should redirect to sign_in' do
        put :update, id: 1
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

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: 1
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

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: 1
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

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: 1
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

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: 1
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

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: 1
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

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: 1
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
      it 'should respond OK by default with referred signups that are not payed' do
        referred_student_2 = FactoryGirl.create(:individual_student_user)
        subscription_2 = FactoryGirl.create(:subscription, user_id: referred_student_2.id)
        referred_signup_2 = FactoryGirl.create(:referred_signup,
                                              user_id: referred_student_2.id,
                                              subscription_id: subscription_2.id,
                                              referral_code_id: tutor_referral_code.id,
                                              payed_at: nil)
        get :index
        expect(assigns(:referred_signups)[0].id).to eq(referred_signup_2.id)
        expect_index_success_with_model('referred_signups', 1)
      end

      it 'should respond OK with all payed referred signups' do
        get :index, payed: 1
        expect_index_success_with_model('referred_signups', 1)
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with referred_signup' do
        get :edit, id: referred_signup.id
        expect_edit_success_with_model('referred_signup', referred_signup.id)
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for referred_signup' do
        put :update, id: referred_signup, referred_signup: { payed_at: Time.now }
        expect_update_success_with_model('referred_signup', referred_signups_url)
      end

      it 'should update only payed_at' do
        now = Time.zone.now
        put :update, id: referred_signup.id, referred_signup: { referral_code_id: tutor_referral_code.id + 1000,
                                                                user_id: referred_student.id + 1000,
                                                                referrer_url: "http://dummy.url",
                                                                subscription_id: subscription.id + 1000,
                                                                maturing_on: now,
                                                                payed_at: now}
        referred_signup.reload
        expect(referred_signup.referral_code_id).to eq(tutor_referral_code.id)
        expect(referred_signup.user_id).to eq(referred_student.id)
        expect(referred_signup.referrer_url).to eq("http://example.com/referral")
        expect(referred_signup.subscription_id).to eq(subscription.id)
        expect(referred_signup.maturing_on).to eq(nil)
        expect(referred_signup.payed_at.strftime("%Y-%m-%d")).to eq(now.strftime("%Y-%m-%d"))
      end
    end
  end

end
