# frozen_string_literal: true

require 'rails_helper'

describe 'Sign out process', type: :feature do
  let(:user_group)      { create(:student_user_group ) }
  let(:student)         { create(:basic_student, :with_group, user_group: user_group) }

  before(:each) do
    sign_in_via_sign_in_page(student)
  end

  context 'User visits the sign in page' do
    scenario 'Loading the sign in page' do
      visit student_dashboard_path

      expect(page).to have_title('Dashboard')
      expect(page).to have_content("#{student.first_name}")

      log_out

      expect(page).to have_title('The Smarter Way to Study | LearnSignal')
      expect(page).to have_content('Login')
    end
  end
end
