# frozen_string_literal: true

require 'rails_helper'
require 'support/free_lesson_content'

describe 'User Onboarding process', type: :feature, js: true do
  include_context 'free_lesson_content'
  before :each do
    allow_any_instance_of(HubSpot::Contacts).to receive(:batch_create).and_return(:ok)
    allow_any_instance_of(HubSpot::FormContacts).to receive(:create).and_return(:ok)
    activate_authlogic
  end

  context 'User visits the onboarding page' do
    let!(:user_group) { create(:student_user_group) }
    let!(:student)    { create(:inactive_student_user, preferred_exam_body: exam_body, user_group: user_group) }

    scenario 'Loading onboarding page' do
      visit user_verification_path(email_verification_code: student.email_verification_code, group_url: group.name_url)
      sleep(3)

      find('#start-screen').should have_content 'Welcome to learnsignal!'

      # Welcome Page
      expect(page).to have_content('Welcome to learnsignal!')
      expect(page).to have_content('We’re delighted you’ve decided to study with us. Let’s get started.')
      expect(page).to have_content('Get started')
      find('.onboarding-get-start').click

      # Level Selection Page
      expect(page).to have_content(group.onboarding_level_heading)
      expect(page).to have_content(group.onboarding_level_subheading)
      expect(page).to have_content(level_1.name)
      find('.onboarding-level').click

      # Course Selection Page
      expect(page).to have_content(level_1.onboarding_course_heading)
      expect(page).to have_content(level_1.onboarding_course_subheading)
      find('.course-link').click

      # Course Step Page - Video
      expect(page).to have_content(course_1.name)
      expect(page).to have_content(course_lesson_1.name)
      expect(page).to have_content(course_step_1.name)
      expect(page).to have_content(course_step_2.name)
      expect(page).to have_selector('div', text: 'keyboard_arrow_left')

      within('.sidebar-nav-btn-right') do
        expect(page).to have_selector('div', text: 'keyboard_arrow_right')
      end

    end
  end

  context 'User visits the root page' do
    let(:group)      { create(:group) }
    let(:user_group) { create(:student_user_group) }
    let(:student)    { create(:inactive_student_user, user_group: user_group) }

    scenario 'Loading root page' do
      visit user_verification_path(email_verification_code: student.email_verification_code, group_url: group.name_url)
      sleep(3)

      find('#flash_message').should have_content 'Thank you! Your email is now verified'
    end
  end
end
