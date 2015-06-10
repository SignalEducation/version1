require 'rails_helper'

RSpec.describe 'referral_codes/index', type: :view do
  before(:each) do
    allow(view).to receive(:tick_or_cross).and_return('nice_boolean')
    @tutor = FactoryGirl.create(:tutor_user)
    @tutor_ref = FactoryGirl.create(:referral_code, user_id: @tutor.id)

    @individual_student = FactoryGirl.create(:individual_student_user)
    @idividual_student_ref = FactoryGirl.create(:referral_code, user_id: @individual_student.id)

    @corporate_student = FactoryGirl.create(:corporate_student_user)
    @corporate_student_ref = FactoryGirl.create(:referral_code, user_id: @corporate_student.id)

    @referral_codes = ReferralCode.paginate(page: 1, per_page: 10)
  end

  it 'renders a list of referral_codes' do
    render
    expect(rendered).to match(@tutor_ref.code)
    expect(rendered).to match(@tutor.full_name)
    expect(rendered).to match(@tutor.email)
  end
end
