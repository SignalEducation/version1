# frozen_string_literal: true

require 'rails_helper'

describe 'An admin user bulk uploads exercises', type: :feature, js: true do
  let(:country) { create(:country, name: 'United Kingdom') }
  let(:student_group) { create(:student_user_group) }
  let(:user) { create(:exercise_corrections_user, :with_group, first_name: 'Admin', last_name: 'User', country: country, currency: country.currency, email_verified: true) }
  let(:file_path) { Rails.root.join('spec/fixtures/exercises/test_bulk_csv.csv') }

  before(:each) do
    user.user_group.update(user_management_access: true)
    @aidan = create(:student_user, user_group: student_group, first_name: 'Aidan1', last_name: 'Quilligan', email: 'a.quilligan@gmail.com')
    @aidan2 = create(:student_user, user_group: student_group, first_name: 'Aidan2', last_name: 'Quilligan', email: 'a.quilligan+41@gmail.com')
    sign_in_via_sign_in_page(user)
  end

  xscenario 'can preview the upload' do
    visit admin_exercises_path
    click_link 'Bulk Assign Exercises'

    page.attach_file('upload_file', file_path)
    click_button('Upload')

    expect(page).to have_content('Upload Preview')
    expect(page).to have_content(@aidan.first_name)
    expect(page).to have_content(@aidan.last_name)
    expect(page).to have_content(@aidan2.first_name)
    expect(page).to have_content(@aidan2.last_name)
    expect(page).not_to have_content('do not exist')
    expect(page).to have_button('Submit')
  end

  xscenario 'can complete the upload' do
    visit admin_exercises_path
    click_link 'Bulk Assign Exercises'

    page.attach_file('upload_file', file_path)
    click_button('Upload')
    click_button('Submit')

    expect(page).to have_content(@aidan.email)
    expect(page).to have_content(@aidan2.email)
    expect(page).to have_content('Processing')
  end
end
