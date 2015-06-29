require 'rails_helper'

RSpec.describe "referred_signups/index.html.haml", type: :view do
  before(:each) do
    @tutor = FactoryGirl.create(:tutor_user)
    @subscription_plan = FactoryGirl.create(:subscription_plan)
    @subscription = FactoryGirl.create(:subscription,
                                        subscription_plan_id: @subscription_plan.id,
                                        user_id: @tutor.id)
    @referral_code = FactoryGirl.create(:referral_code,
                                        user_id: @tutor.id)

    @referred_student = FactoryGirl.create(:individual_student_user)
    @referred_signup = FactoryGirl.create(:referred_signup,
                                          user_id: @referred_student.id,
                                          referral_code_id: @referral_code.id,
                                          subscription_id: @subscription.id,
                                          referrer_url: "http://example.com/referral",
                                          maturing_on: 5.days.ago,
                                          payed_at: 3.days.ago)
    @referred_signups = ReferredSignup.paginate(per_page: 1, page: 1)
  end

  it 'renders a list of referred_signups' do
    render
    expect(rendered).to match(@tutor.full_name)
    expect(rendered).to match(@referral_code.code)
    expect(rendered).to match(@referred_signup.referrer_url)
    expect(rendered).to match(@referred_student.full_name)
    expect(rendered).to match(@subscription_plan.description.chomp.gsub("\r\n", ", "))
    expect(rendered).to match(@referred_signup.maturing_on.strftime("%Y-%m-%d"))
    expect(rendered).to match(@referred_signup.payed_at.strftime("%Y-%m-%d"))
  end
end
