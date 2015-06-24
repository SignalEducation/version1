require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'Admin/Tutor uploading flash card packs:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  before(:each) do
    activate_authlogic
    expect(tutor_user.id).to be > 0
  end

  describe 'Uploading flash cards/quizzes' do

    scenario 'uploading card and quiz content', js: true  do
      visit root_path
      click_link 'Sign In'
      within('.well.well-sm') do
        fill_in I18n.t('views.user_sessions.form.email'), with: admin_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: admin_user.password
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content I18n.t('controllers.user_sessions.create.flash.success')
      within('#navbar') do
        click_link 'Tools'
        click_link 'Course Modules'
      end
      expect(page).to have_content 'Course Modules'
      expect(page).to have_content course_module_1.name
      expect(page).to have_content course_module_element_1_1.name
      click_link 'New Flash Card Pack'
      expect(page).to have_content 'New Course Module Element'
      expect(page).to have_content 'Flash Card Pack'
      within('.well.well-sm') do
        fill_in 'Name', with: 'CME Pack 1'
        fill_in 'Name URL', with: 'cme-pack-1'
        fill_in 'Description', with: 'My lovely horse running through a field'
        fill_in 'SEO description', with: ('abc' * 50)
        check 'SEO no-index flag'
        fill_in 'Estimated time (seconds)', with: '123'
      end
      page.all(:css, '#stack-title input').first.set('CME Stack 1')
      page.all(:css, '#stack-btn input').first.set('Next!')
      within('.panel-body') do
        page.find(:css, '.quiz_content_text textarea', match: :first).set('ABC' * 100)
        click_link 'plus-btn'
        page.all(:css, '.quiz_content_text textarea').last.set('123' * 100)
        minus_btn = page.all(:id, 'minus-btn', match: :first).first
        minus_btn.click
        page.driver.browser.switch_to.alert.accept
        click_link 'Add a new Flash Card'
        page.all(:css, '.quiz_content_text textarea').last.set('123' * 100)
        click_link 'Add a new Flash Card'
        page.all(:css, '.quiz_content_text textarea').last.set('xyz' * 100)
      end
      click_link 'Add a new card stack'
      page.all(:css, '#stack-title input').last.set('CME Stack 2')
      page.all(:css, '#stack-btn input').last.set('Go!')
      within('.panel-body') do
        page.find(:css, '.quiz_content_text textarea', match: :first).set('ABC' * 100)
        click_link 'plus-btn'
        page.all(:css, '.quiz_content_text textarea').last.set('123' * 100)
        click_link 'Add a new Flash Card'
        page.all(:css, '.quiz_content_text textarea').last.set('123' * 100)
      end
      click_button 'Save'
      expect(page).to have_content 'Course Module Element has been created successfully'
      page.all(:id, 'edit-btn').last.click
      expect(page).to have_content 'Edit Course Module Element'
      expect(page).to have_content 'Card #3'
      page.all(:id, 'delete-card').last.click
      page.driver.browser.switch_to.alert.accept
      page.all(:id, 'delete-card').last.click
      page.driver.browser.switch_to.alert.accept
      page.all(:id, 'delete-stack').first.click
      page.driver.browser.switch_to.alert.accept
      expect(page).to_not have_content 'CME Stack 1'
      click_link 'Add a new card stack'
      within(page.all(:css, '.panel-heading').last) do
        page.all(:css, '#stack-title input').last.set('CME Stack 3')
        page.all(:css, '#stack-btn input').last.set('Continue!')
        find('#content-type-select').select('Quiz')
      end
      within('.panel-body') do
        page.all(:css, '.quiz-question textarea').first.set('Question Text 1')
        page.all(:css, '.quiz-answer-text textarea').first.set('Answer 11')
        page.all(:css, '.quiz-answer-text textarea').last.set('Answer 12')
        page.all(:css, '#degree-of-wrongness').first.select('slightly wrong')
        page.all(:css, '#degree-of-wrongness').last.select('correct')
      end
      click_button 'Save'
      expect(page).to have_content 'Course Module Element details have been updated successfully'
      page.all(:id, 'edit-btn').last.click
      expect(page).to have_content 'Edit Course Module Element'
      page.all(:css, '#closed').last.click
      click_link 'Add a new question'
      within all('.well.well-sm.question')[1] do
        page.all(:css, '.quiz-question textarea').last.set('Question Text 2')
        page.all(:css, '.quiz-answer-text textarea').first.set('Answer 21')
        page.all(:css, '.quiz-answer-text textarea').last.set('Answer 22')
        page.all(:css, '#degree-of-wrongness').first.select('correct')
        page.all(:css, '#degree-of-wrongness').last.select('slightly wrong')
        click_link 'Add an extra answer'
        page.all(:css, '.quiz-answer-text textarea')[2].set('Answer 23')
        page.all(:css, '#degree-of-wrongness')[2].select('wrong')
      end
      click_link 'Add a new question'
      within all('.well.well-sm.question')[2] do
        page.all(:css, '.quiz-question textarea').last.set('Question Text 3')
        page.all(:css, '.quiz-answer-text textarea').first.set('Answer 31')
        page.all(:css, '.quiz-answer-text textarea').last.set('Answer 32')
        page.all(:css, '#degree-of-wrongness').first.select('correct')
        page.all(:css, '#degree-of-wrongness').last.select('slightly wrong')
      end
      click_link 'Add a new question'
      within all('.well.well-sm.question')[3] do
        page.all(:css, '.quiz-question textarea').last.set('Question Text 4')
        page.all(:css, '.quiz-answer-text textarea').first.set('Answer 41')
        page.all(:css, '.quiz-answer-text textarea').last.set('Answer 42')
        page.all(:css, '#degree-of-wrongness').first.select('correct')
        page.all(:css, '#degree-of-wrongness').last.select('slightly wrong')
      end
      click_button 'Save'
      expect(page).to have_content 'Course Module Element details have been updated successfully'
    end
  end

end
