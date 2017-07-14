require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'CME management by admin/content_manager: ', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  before(:each) do
    activate_authlogic
    a = admin_user
    b = individual_student_user
    e = comp_user
    f = content_manager_user
    g = tutor_user

    sign_in_via_sign_in_page(content_manager_user)
    find('.dropdown.dropdown-normal').click
    click_link(I18n.t('views.subject_courses.index.manager_courses'))
    expect(page).to have_content(I18n.t('views.subject_courses.index.h1'))
  end

  describe 'successfully creates' do
    scenario 'an active CMEQ', js: true do
      within('.table-responsive') do
        page.find('tr', :text => subject_course_1.name).click_link('Edit Content')
      end

      click_link(I18n.t('views.course_module_elements.form.new_quiz'))
      cme_1_name = 'CMEQ 001'
      cme_1_name_url = 'cmeq-001'
      question_1_text = 'Question 001 Text Content'
      solution_1_text = 'Solution 001 Text Content'
      answer_1_text = 'Answer 001 Text Content'
      answer_2_text = 'Answer 002 Text Content'
      answer_3_text = 'Answer 003 Text Content'
      answer_4_text = 'Answer 004 Text Content'
      within('#course_module_element_form') do
        fill_in I18n.t('views.course_module_elements.form.name'), with: cme_1_name
        fill_in I18n.t('views.course_module_elements.form.name_url'), with: cme_1_name_url
        select '1', from: I18n.t('views.course_module_element_quizzes.form.number_of_questions')
        select 'random', from: I18n.t('views.course_module_element_quizzes.form.question_selection_strategy')
        fill_in I18n.t('views.course_module_elements.form.estimated_time_in_seconds'), with: 100

        within('.question-box-item') do
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_contents_attributes_0_text_content', with: question_1_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_solutions_attributes_0_text_content', with: solution_1_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_0_quiz_contents_attributes_0_text_content', with: answer_1_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_1_quiz_contents_attributes_0_text_content', with: answer_2_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_2_quiz_contents_attributes_0_text_content', with: answer_3_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_3_quiz_contents_attributes_0_text_content', with: answer_4_text)

          select 'correct', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_0_degree_of_wrongness'
          select 'incorrect', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_1_degree_of_wrongness'
          select 'incorrect', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_2_degree_of_wrongness'
          select 'incorrect', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_3_degree_of_wrongness'
        end

        click_button(I18n.t('views.general.save'))
      end
      expect(page).to have_content(I18n.t('controllers.course_module_elements.create.flash.success'))
    end
  end

  describe 'fails to create' do
    scenario 'a CMEQ due to CME validation', js: true do
      within('.table-responsive') do
        page.find('tr', :text => subject_course_1.name).click_link('Edit Content')
      end

      click_link(I18n.t('views.course_module_elements.form.new_quiz'))
      cme_1_name = ''
      question_1_text = 'Question 001 Text Content'
      solution_1_text = 'Solution 001 Text Content'
      answer_1_text = 'Answer 001 Text Content'
      answer_2_text = 'Answer 002 Text Content'
      answer_3_text = 'Answer 003 Text Content'
      answer_4_text = 'Answer 004 Text Content'
      within('#course_module_element_form') do
        fill_in I18n.t('views.course_module_elements.form.name'), with: cme_1_name
        select '1', from: I18n.t('views.course_module_element_quizzes.form.number_of_questions')
        select 'random', from: I18n.t('views.course_module_element_quizzes.form.question_selection_strategy')
        fill_in I18n.t('views.course_module_elements.form.estimated_time_in_seconds'), with: 100

        within('.question-box-item') do
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_contents_attributes_0_text_content', with: question_1_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_solutions_attributes_0_text_content', with: solution_1_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_0_quiz_contents_attributes_0_text_content', with: answer_1_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_1_quiz_contents_attributes_0_text_content', with: answer_2_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_2_quiz_contents_attributes_0_text_content', with: answer_3_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_3_quiz_contents_attributes_0_text_content', with: answer_4_text)

          select 'correct', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_0_degree_of_wrongness'
          select 'incorrect', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_1_degree_of_wrongness'
          select 'incorrect', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_2_degree_of_wrongness'
          select 'incorrect', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_3_degree_of_wrongness'
        end

        click_button(I18n.t('views.general.save'))
      end
      expect(page).to_not have_content(I18n.t('controllers.course_module_elements.create.flash.success'))
      expect(page).to have_content("Name can't be blank")

    end

    scenario 'a CMEQ due to QQ validation', js: true do
      within('.table-responsive') do
        page.find('tr', :text => subject_course_1.name).click_link('Edit Content')
      end

      click_link(I18n.t('views.course_module_elements.form.new_quiz'))
      cme_1_name = 'CMEQ 001'
      question_1_text = ''
      solution_1_text = 'Solution 001 Text Content'
      answer_1_text = 'Answer 001 Text Content'
      answer_2_text = 'Answer 002 Text Content'
      answer_3_text = 'Answer 003 Text Content'
      answer_4_text = 'Answer 004 Text Content'
      within('#course_module_element_form') do
        fill_in I18n.t('views.course_module_elements.form.name'), with: cme_1_name
        select '1', from: I18n.t('views.course_module_element_quizzes.form.number_of_questions')
        select 'random', from: I18n.t('views.course_module_element_quizzes.form.question_selection_strategy')
        fill_in I18n.t('views.course_module_elements.form.estimated_time_in_seconds'), with: 100

        within('.question-box-item') do
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_contents_attributes_0_text_content', with: question_1_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_solutions_attributes_0_text_content', with: solution_1_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_0_quiz_contents_attributes_0_text_content', with: answer_1_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_1_quiz_contents_attributes_0_text_content', with: answer_2_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_2_quiz_contents_attributes_0_text_content', with: answer_3_text)
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_3_quiz_contents_attributes_0_text_content', with: answer_4_text)

          select 'correct', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_0_degree_of_wrongness'
          select 'incorrect', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_1_degree_of_wrongness'
          select 'incorrect', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_2_degree_of_wrongness'
          select 'incorrect', from: 'course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_answers_attributes_3_degree_of_wrongness'
        end

        click_button(I18n.t('views.general.save'))
      end
      expect(page).to_not have_content(I18n.t('controllers.course_module_elements.create.flash.success'))
      expect(page).to have_content("Course module element quiz.quiz questions.quiz contents.text content can't be blank")

    end
  end

  describe 'successfully edits' do
    scenario 'a CMEQ due to CME validation', js: true do
      within('.table-responsive') do
        page.find('tr', :text => subject_course_1.name).click_link('Edit Content')
      end
      within('.table-responsive') do
        page.find('tr', :text => course_module_element_1_1.name).click_link(I18n.t('views.general.edit'))
      end
      cme_1_name = 'Edited - CMEQ 001'
      within('#course_module_element_form') do
        fill_in I18n.t('views.course_module_elements.form.name'), with: cme_1_name
      end

      click_button(I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('controllers.course_module_elements.update.flash.success'))
      expect(page).to_not have_content("Name can't be blank")
    end

  end

  describe 'fails to edit' do
    scenario 'a CME due to CME validation', js: true do
      within('.table-responsive') do
        page.find('tr', :text => subject_course_1.name).click_link('Edit Content')
      end
      within('.table-responsive') do
        page.find('tr', :text => course_module_element_1_1.name).click_link(I18n.t('views.general.edit'))
      end
      cme_1_name = ''
      within('#course_module_element_form') do
        fill_in I18n.t('views.course_module_elements.form.name'), with: cme_1_name
      end

      click_button(I18n.t('views.general.save'))

      expect(page).to_not have_content(I18n.t('controllers.course_module_elements.create.flash.success'))
      expect(page).to have_content("Name can't be blank")

    end

    scenario 'a CMEQ due to QQ validation', js: true do
      within('.table-responsive') do
        page.find('tr', :text => subject_course_1.name).click_link('Edit Content')
      end
      within('.table-responsive') do
        page.find('tr', :text => course_module_element_1_1.name).click_link(I18n.t('views.general.edit'))
      end

      question_1_text = ''
      within('#course_module_element_form') do

        within("#question_#{quiz_question_1.id}") do
          fill_in('course_module_element_course_module_element_quiz_attributes_quiz_questions_attributes_0_quiz_contents_attributes_0_text_content', with: question_1_text)
        end

        click_button(I18n.t('views.general.save'))
      end
      expect(page).to_not have_content(I18n.t('controllers.course_module_elements.create.flash.success'))
      expect(page).to have_content("Course module element quiz.quiz questions.quiz contents.text content can't be blank")

    end
  end

  describe 'successfully deletes' do
    scenario 'a CMEQ', js: true do
      within('.table-responsive') do
        page.find('tr', :text => subject_course_1.name).click_link('Edit Content')
      end
      within('.table-responsive') do
        page.find('tr', :text => course_module_element_1_1.name).click_link(I18n.t('views.general.delete'))
      end

      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content(I18n.t('controllers.course_module_elements.destroy.flash.success'))
    end


  end

end
