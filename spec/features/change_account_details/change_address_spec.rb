require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their email' do

  include_context 'users_and_groups_setup'

  let!(:country_1) { FactoryGirl.create(:ireland) }
  let!(:country_2) { FactoryGirl.create(:uk) }
  let!(:static_page) { FactoryGirl.create(:static_page) }

  before(:each) do
    activate_authlogic
  end

  scenario 'when logged in as an individual_student_user', js: true do
    visit root_path
    sleep 10
    within('.well.well-sm') do
      fill_in I18n.t('views.user_sessions.form.email'), with: individual_student_user.email
      fill_in I18n.t('views.user_sessions.form.password'), with: individual_student_user.password
      click_button I18n.t('views.general.go')
    end
    expect(page).to have_content 'Welcome back!'

    click_link('navbar-cog')
    click_link(I18n.t('views.users.show.h1'))
    expect(page).to have_content I18n.t('views.users.show.h1')
    click_link I18n.t('views.general.edit')
    expect(page).to have_content I18n.t('views.users.edit.h1')
    fill_in I18n.t('views.users.form.address_placeholder'), with: '123 Fake Street'
    click_button(I18n.t('views.general.save'))
    expect(page).to have_content 'User details have been updated successfully'
    expect(page).to have_content I18n.t('views.users.show.h1')
  end

end