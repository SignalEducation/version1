require 'rails_helper'

RSpec.describe "referred_signups/edit.html.haml", type: :view do
  before(:each) do

    @tutor_user_group = FactoryGirl.create(:tutor_user_group)
    @tutor = FactoryGirl.create(:tutor_user, user_group_id: @tutor_user_group.id )
    @tutor_referral_code = FactoryGirl.create(:referral_code, user_id: @tutor.id)
    @referred_student = FactoryGirl.create(:individual_student_user)
    @subscription = FactoryGirl.create(:subscription, user_id: @referred_student.id)
    @referred_signup = FactoryGirl.create(:referred_signup,
                                          user_id: @referred_student.id,
                                          subscription_id: @subscription.id,
                                          referral_code_id: @tutor_referral_code.id)
  end

  it 'renders edit referred signup form' do
    render
    assert_select 'form[action=?][method=?]', referred_signup_path(id: @referred_signup.id), 'post' do
      assert_select 'select#referred_signup_payed_at_1i[name=?]', 'referred_signup[payed_at(1i)]'
      assert_select 'select#referred_signup_payed_at_2i[name=?]', 'referred_signup[payed_at(2i)]'
      assert_select 'select#referred_signup_payed_at_3i[name=?]', 'referred_signup[payed_at(3i)]'
    end
  end
end
