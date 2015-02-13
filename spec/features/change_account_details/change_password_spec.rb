require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User changing their password' do

  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
  end

  scenario 'when logged in as an individual_student_user' do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in I18n.t('views.user_sessions.form.email'), with: individual_student_user.email
      fill_in I18n.t('views.user_sessions.form.password'), with: individual_student_user.password
      click_button I18n.t('views.general.go')
    end
    expect(page).to have_content 'Welcome back!'
    click_link('navbar-cog')
    click_link(I18n.t('views.users.show.h1'))
    expect(page).to have_content I18n.t('views.users.show.h1')
    click_link I18n.t('views.users.show.change_your_password.link')
    expect(page).to have_content I18n.t('views.users.show.change_your_password.h4')
    fill_in I18n.t('views.users.form.current_password'), with: individual_student_user.password
    sleep 1
    fill_in I18n.t('views.users.form.password'), with: 'abcabc123'
    fill_in I18n.t('views.users.form.password_confirmation'), with: 'abcabc123'
    click_button I18n.t('views.general.save')
    expect(page).to have_content 'Your password has been updated successfully'
  end

end