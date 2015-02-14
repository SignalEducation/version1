require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'

describe 'The password reset process,', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'

  before(:each) do
    activate_authlogic
    visit root_path
    click_link I18n.t('views.general.sign_up')
    expect(page).to have_content maybe_upcase I18n.t('views.student_sign_ups.new.h1')
  end

  scenario 'sign-up with valid details - Ireland and Euro', js: true do
    sleep 10
  end

end
