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
    within('h1') do
      expect(page).to have_content maybe_upcase I18n.t('views.library.show.h1')
    end
    expect(page).to_not have_content I18n.t('views.general.back')
    expect(page).to have_content maybe_upcase I18n.t('views.subject_areas.index.h1')
    expect(page).to have_content maybe_upcase 'Lorem Ipsum'
    expect(page).to have_content maybe_upcase institution_1.name
    expect(page).to have_content qualification_1.name
    within('#subject-area-panel') do
      find_link('Subject Area 2').click
    end
    expect(page).to have_content maybe_upcase I18n.t('views.subject_areas.index.h1')
    # the library skips down the hierarchy to exam_level_2
    expect(page).to have_content maybe_upcase exam_level_2.name
    expect(page).to have_content maybe_upcase 'Lorem Ipsum'
    sleep 10
    expect(page).to have_content course_module_element_2_1.name
  end

end
