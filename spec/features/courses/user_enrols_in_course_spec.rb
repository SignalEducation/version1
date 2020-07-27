# frozen_string_literal: true

require 'rails_helper'

describe 'A user enrols in a course', type: :feature, js: true do
  let(:country) { create(:country, name: 'United Kingdom') }
  let(:exam_body) { create(:exam_body, :with_group, has_sittings: true) }
  let(:user) { create(:student_user, preferred_exam_body: exam_body, country: country, currency: country.currency) }
  let!(:course) { create(:active_course, group: exam_body.group, exam_body: exam_body) }

  before(:each) do
    create(:standard_exam_sitting, course: course, exam_body: course.exam_body, date: Date.today + 1.week)
    sign_in_via_sign_in_page(user)
  end

  context 'with a basic subscription' do
    scenario 'the user can enrol' do
      expect(page).to have_content('Dashboard')
      expect(page).to have_link('Activity')

      click_link course.name

      click_link 'Enrol'
      all('#exam_sitting_select option', minimum: 1)[1].select_option
      click_button 'Next Step'
      fill_in "#{exam_body} Student Number", with: '12345'
      all('#user_date_of_birth_3i option')[1].select_option
      all('#user_date_of_birth_2i option')[1].select_option
      all('#user_date_of_birth_1i option')[1].select_option
      click_button 'Complete Enrolment'

      expect(page).to have_content "Thank you. You have successfully enrolled in #{course.name}"
    end
  end
end
