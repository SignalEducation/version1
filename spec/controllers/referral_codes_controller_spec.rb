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

describe ReferralCodesController, type: :controller do

  let(:user_management_user_group) { FactoryBot.create(:user_management_user_group) }
  let(:user_management_user) { FactoryBot.create(:user_management_user, user_group_id: user_management_user_group.id) }
  let!(:user_management_student_access) { FactoryBot.create(:complimentary_student_access, user_id: user_management_user.id) }

  let(:tutor_user_group) { FactoryBot.create(:tutor_user_group) }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }

  let!(:tutor) { FactoryBot.create(:tutor_user, user_group_id: tutor_user_group.id ) }
  let!(:student_user) { FactoryBot.create(:student_user, user_group_id: student_user_group.id) }
  let!(:referred_signup) { FactoryBot.create(:referred_signup, referral_code_id: tutor.referral_code.id, user_id: student_user.id) }

  context 'Logged in as a user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('referral_codes', 1)
      end
    end
    
    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: tutor.referral_code.id
        expect_delete_success_with_model('referral_code', referral_codes_url)
      end
    end

    describe "Post 'referral'" do
      it 'redirect to root' do
        #TODO test cookie dropping
        post :referral, ref_code: tutor.referral_code.code
        expect(response).to redirect_to(root_url)
      end
    end

  end

end
