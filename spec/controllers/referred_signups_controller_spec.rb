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

RSpec.describe ReferredSignupsController, type: :controller do

  let(:user_management_user_group) { FactoryBot.create(:user_management_user_group) }
  let(:tutor_user_group) { FactoryBot.create(:tutor_user_group) }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }

  let(:user_management_user) { FactoryBot.create(:user_management_user, user_group_id: user_management_user_group.id) }
  let!(:user_management_student_access) { FactoryBot.create(:complimentary_student_access, user_id: user_management_user.id) }

  let!(:tutor) { FactoryBot.create(:tutor_user, user_group_id: tutor_user_group.id ) }
  let!(:referred_student) { FactoryBot.create(:student_user) }
  let!(:subscription) { FactoryBot.create(:subscription, user_id: referred_student.id) }
  let!(:referred_signup) { FactoryBot.create(:referred_signup,
                                              user_id: referred_student.id,
                                              subscription_id: subscription.id,
                                              referral_code_id: tutor_referral_code.id) }


  #TODO - this needs a complete overhaul
  context 'Logged in as a user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe "GET 'index'" do
      xit 'should respond OK by default with referred signups that are not payed' do
        referred_student_2 = FactoryBot.create(:student_user)
        subscription_2 = FactoryBot.create(:subscription, user_id: referred_student_2.id)
        referred_signup_2 = FactoryBot.create(:referred_signup,
                                              user_id: referred_student_2.id,
                                              subscription_id: subscription_2.id,
                                              referral_code_id: tutor.referral_code.id,
                                              payed_at: nil)
        get :index
        expect(assigns(:referred_signups)[0].id).to eq(referred_signup_2.id)
        expect_index_success_with_model('referred_signups', 1)
      end

      xit 'should respond OK with all payed referred signups' do
        get :index, payed: 1
        expect_index_success_with_model('referred_signups', 1)
      end
    end

    describe "GET 'edit/1'" do
      xit 'should respond OK with referred_signup' do
        get :edit, id: referred_signup.id
        expect_edit_success_with_model('referred_signup', referred_signup.id)
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params for referred_signup' do
        put :update, id: referred_signup, referred_signup: { payed_at: Time.now }
        expect_update_success_with_model('referred_signup', referred_signups_url)
      end

      xit 'should update only payed_at' do
        now = Time.zone.now
        put :update, id: referred_signup.id, referred_signup: { referral_code_id: tutor.referral_code.id + 1000,
                                                                user_id: referred_student.id + 1000,
                                                                referrer_url: "http://dummy.url",
                                                                subscription_id: subscription.id + 1000,
                                                                maturing_on: now,
                                                                payed_at: now}
        referred_signup.reload
        expect(referred_signup.referral_code_id).to eq(tutor.referral_code.id)
        expect(referred_signup.user_id).to eq(referred_student.id)
        expect(referred_signup.referrer_url).to eq("http://example.com/referral")
        expect(referred_signup.subscription_id).to eq(subscription.id)
        expect(referred_signup.maturing_on).to eq(nil)
        expect(referred_signup.payed_at.strftime("%Y-%m-%d")).to eq(now.strftime("%Y-%m-%d"))
      end
    end

  end

end
