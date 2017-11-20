# == Schema Information
#
# Table name: referral_codes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  code       :string(7)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe ReferralCodesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:tutor) { FactoryGirl.create(:tutor_user, user_group_id: tutor_user_group.id ) }
  let!(:tutor_referral_code) { FactoryGirl.create(:referral_code, user_id: tutor.id) }
  let!(:blogger) { FactoryGirl.create(:blogger_user, user_group_id: blogger_user_group.id ) }
  let!(:blogger_referral_code) { FactoryGirl.create(:referral_code, user_id: blogger.id) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
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

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: tutor_referral_code.id
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

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: tutor_referral_code.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: tutor_referral_code.id
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
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('referral_codes', 2)
      end
    end
    
    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        student_user = FactoryGirl.create(:student_user)
        student_user.create_referred_signup(referral_code_id: tutor_referral_code.id,
                                                       subscription_id: 1)
        delete :destroy, id: tutor_referral_code.id
        expect_delete_error_with_model('referral_code', referral_codes_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor_referral_code.id
        expect_delete_success_with_model('referral_code', referral_codes_url)
      end
    end

  end

end
