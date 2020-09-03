# frozen_string_literal: true

require 'rails_helper'

describe 'User Onboarding process', type: :feature, js: true do
  before :each do
    allow_any_instance_of(HubSpot::Contacts).to receive(:batch_create).and_return(:ok)
    allow_any_instance_of(HubSpot::FormContacts).to receive(:create).and_return(:ok)
    activate_authlogic
  end

  context 'User visits the onboarding page' do
    let(:group)      { create(:group) }
    let(:user_group) { create(:student_user_group) }
    let(:student)    { create(:inactive_student_user, :with_group, user_group: user_group) }

    xscenario 'Loading onboarding page' do
      visit user_verification_path(email_verification_code: student.email_verification_code, group_url: group.name_url)

      expect(page).to have_content('Welcome to learnsignal!')
      expect(page).to have_content('We’re delighted you’ve decided to study with us. Let’s get started.')

      find('.onboarding-select').click
      sleep(3)

      expect(page).to have_content(student.preferred_exam_body.group.onboarding_level_heading)
      expect(page).to have_content(student.preferred_exam_body.group.onboarding_level_subheading)
      expect(page).to have_content(student.preferred_exam_body.group.levels.sample.name)
    end
  end

  context 'User visits the root page' do
    let(:group)      { create(:group) }
    let(:user_group) { create(:student_user_group) }
    let(:student)    { create(:inactive_student_user, user_group: user_group) }

    xscenario 'Loading root page' do
      visit user_verification_path(email_verification_code: student.email_verification_code, group_url: group.name_url)

      expect(page).to have_content('Thank you! Your email is now verified')
    end
  end
end
