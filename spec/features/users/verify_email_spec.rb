# frozen_string_literal: true

require 'rails_helper'

describe 'Verify Account process', type: :feature do
  let(:user_group)      { create(:student_user_group ) }
  let(:student)         { create(:unverified_user, :with_group, user_group: user_group) }

  before :each do
    activate_authlogic
    visit user_verification_path(email_verification_code: student.email_verification_code)
  end

  context 'User start onboarding page' do
    scenario 'Loading the onboarding page after verify' do
      expect(page).to have_content('Welcome to learnsignal!')
      expect(page).to have_content('We’re delighted you’ve decided to study with us. Let’s get started.')
    end
  end
end