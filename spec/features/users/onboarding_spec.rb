# frozen_string_literal: true

require 'rails_helper'

describe 'User Onboarding process', type: :feature do
  before :each do
    activate_authlogic
  end

  context 'User visits the onboarding page' do
    let(:group)      { create(:group) }
    let(:user_group) { create(:student_user_group) }
    let(:student)    { create(:inactive_student_user, :with_group, user_group: user_group) }

    scenario 'Loading onboarding page', js: true do
      visit user_verification_path(email_verification_code: student.email_verification_code, group_url: group.name_url)

      expect(page).to have_content('Welcome to learnsignal!')
      expect(page).to have_content('We’re delighted you’ve decided to study with us. Let’s get started.')

      find('.onboarding-select').click
      sleep(2)

      expect(page).to have_content(student.preferred_exam_body.group.onboarding_level_heading)
      expect(page).to have_content(student.preferred_exam_body.group.onboarding_level_subheading)
      expect(page).to have_content(student.preferred_exam_body.group.levels.sample.name)
    end
  end

  context 'User visits the root page' do
    let(:group)      { create(:group) }
    let(:user_group) { create(:student_user_group) }
    let(:student)    { create(:inactive_student_user, user_group: user_group) }

    scenario 'Loading root page', js: true do
      visit user_verification_path(email_verification_code: student.email_verification_code, group_url: group.name_url)

      expect(page).to have_content('Thank you! Your email is now verified')
    end
  end
end