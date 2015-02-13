require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'User navigating through the library:' do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:static_page) { FactoryGirl.create(:landing_page) }

  before(:each) do
    activate_authlogic
  end

  scenario 'user signs in then navigates down hierarchy to first cme', js: true  do
    visit root_path
    click_link 'Library'
    expect(page).to have_content I18n.t('views.general.home')
    expect(page).to have_content I18n.t('views.library.show.h1').upcase
    expect(page).to_not have_content I18n.t('views.general.back')
    expect(page).to have_content I18n.t('views.subject_areas.index.h1').upcase
    expect(page).to have_content 'Lorem Ipsum'.upcase
    expect(page).to have_content 'Institute 1'.upcase
    expect(page).to have_content 'Qualification 1'
    within('#subject-area-panel') do
      find_link('Subject Area 2').click
    end
    expect(page).to have_content I18n.t('views.subject_areas.index.h1').upcase
    expect(page).to have_content 'Institute 2'.upcase
    expect(page).to have_content 'Lorem Ipsum'.upcase
    expect(page).to have_content 'Qualification 3'

  end

end