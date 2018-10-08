require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'

describe 'Navigation of footer pages', type: :feature do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'


  before(:each) do
    activate_authlogic
  end

  scenario 'successfully visit each footer page', js: false do

    visit privacy_policy_path
    expect(page).to have_content 'Our privacy outline for Learn Signal'

    visit acca_info_path
    expect(page).to have_content 'ACCA Student Support Guidelines'

    visit welcome_video_path
    expect(page).to have_content 'Introduction Video'

    visit contact_path
    expect(page).to have_content 'Contact Us'

    visit terms_and_conditions_path
    expect(page).to have_content 'Terms & Conditions'

    visit public_faqs_path
    expect(page).to have_content 'FAQs'

    visit tutors_path
    expect(page).to have_content 'Our Lecturers'

  end

end
