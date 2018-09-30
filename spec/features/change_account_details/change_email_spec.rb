require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'User changing their email', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:country_1) { try(:country) || FactoryBot.create(:ireland)}
  let!(:country_2) { FactoryBot.create(:uk)}

  before(:each) do
    activate_authlogic
  end

  scenario 'should be able to change email', js: false do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile

      within('#modal-links') do
        find('.edit-details').click
      end

      within('#personal-details-form') do
        fill_in I18n.t('views.users.form.email'), with: "user#{rand(9999)}@example.com"
        click_button(I18n.t('views.general.actual_submit'))
      end
      sign_out
      print '>'
    end
  end
  sleep(1)
end
