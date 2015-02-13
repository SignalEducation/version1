# Some methods that are auto-loaded by rails_helper.rb into every RSpec test.

######
## features
##

def sign_in_via_navbar(user)

end

def sign_in_via_sign_in_page(user)
  visit sign_in_path
  within('.well.well-sm') do
    fill_in I18n.t('views.user_sessions.form.email'), with: user.email
    fill_in I18n.t('views.user_sessions.form.password'), with: user.password
    click_button I18n.t('views.general.go')
  end
  expect(page).to have_content I18n.t('controllers.user_sessions.create.flash.success')
end

def sign_out
  click_link('navbar-cog')
  click_link(I18n.t('views.general.sign_out'))
end

def maybe_upcase(thing)
 Capybara.current_driver == Capybara.javascript_driver ? thing.upcase : thing
end

def visit_my_profile
  click_link('navbar-cog')
  click_link(I18n.t('views.users.show.h1'))
  expect(page).to have_content maybe_upcase I18n.t('views.users.show.h1')
end

def edit_my_profile
  visit_my_profile
  click_link I18n.t('views.general.edit')
  expect(page).to have_content maybe_upcase I18n.t('views.users.edit.h1')
end
