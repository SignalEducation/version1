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

    @referred_students_not_matured = FactoryGirl.create_list(:individual_student_user, 5)
    @referred_students_not_matured.each { |rsnm| FactoryGirl.create(:referred_signup,
                                                                    user_id: rsnm.id,
                                                                    referral_code_id: @tutor_ref.id) }

    @referred_students_payed = FactoryGirl.create_list(:individual_student_user, 5)
    @referred_students_payed.each { |rsnm| FactoryGirl.create(:referred_signup,
                                                              user_id: rsnm.id,
                                                              referral_code_id: @tutor_ref.id,
                                                              payed_at: 2.days.ago) }

    @referred_students_for_paying = FactoryGirl.create_list(:individual_student_user, 5)
    @referred_students_for_paying.each { |rsnm| FactoryGirl.create(:referred_signup,
                                                                   user_id: rsnm.id,
                                                                   referral_code_id: @tutor_ref.id,
                                                                   maturing_on: 1.day.ago) }
  end

  it 'renders a list of referral_codes' do
    render
    expect(rendered).to match(@tutor_ref.code)
    expect(rendered).to match(@tutor.full_name)
    expect(rendered).to match(@tutor.email)
    expect(rendered).to match(@referred_students_not_matured.length.to_s)
    expect(rendered).to match(@referred_students_payed.length.to_s)
    expect(rendered).to match(@referred_students_for_paying.length.to_s)
  end
end
