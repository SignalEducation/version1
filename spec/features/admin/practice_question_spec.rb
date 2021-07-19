require 'rails_helper'

describe 'Admin creates/edits a practice question', type: :feature do
  let(:user)                            { create(:user) }
  let(:course_lesson)                   { create(:course_lesson) }
  let!(:course_step)                    { create(:course_step, :practice_question_step, course_lesson: course_lesson) }
  let!(:course_step_exh)                { create(:course_step, :practice_question_step, course_lesson: course_lesson) }
  let!(:course_practice_question)       { create(:course_practice_question, course_step_id: course_step.id) }
  let!(:course_practice_question_exh)   { create(:course_practice_question, course_step_id: course_step_exh.id, kind: 'exhibit') }
  let(:file_path)                       { Rails.root.join('spec/fixtures/test_exercise_submission.pdf') }
  let!(:question_standard_open)         { create(:practice_question_questions, practice_question: course_practice_question, kind: 'open', sorting_order: 1) }
  let!(:question_standard_spreadhseet)  { create(:practice_question_questions, practice_question: course_practice_question, kind: 'spreadsheet', sorting_order: 2) }
  let!(:question_exhibit_open)          { create(:practice_question_questions, practice_question: course_practice_question_exh, kind: 'open', sorting_order: 1) }
  let!(:question_exhibit_spreadhseet)   { create(:practice_question_questions, practice_question: course_practice_question_exh, kind: 'spreadsheet', sorting_order: 2) }

  context 'Admin creates a practice question' do
    before :each do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)
      allow(course_lesson).to receive(:all_content_restricted?).and_return(true)
    end

    scenario 'Create open question standard', js: true do
      visit new_admin_course_step_path(type: 'practice_question', cm_id: course_lesson.id)
      fill_in 'course_step[course_practice_question_attributes][estimated_time]', with: '15700'
      fill_in 'course_step[name]', with: 'New Practice Question 1'
      select 'Standard', from: 'course_step_course_practice_question_attributes_kind'
      page.attach_file('Upload help file', file_path)
      fill_in 'course_step[temporary_label]', with: 'PQ1Label'
      within all('div[contenteditable]')[0] do
        find('p').set('Scenario Content 1')
      end
      fill_in 'course_step[course_practice_question_attributes][questions_attributes][0][name]', with: 'Question A'
      select 'Open', from: 'course_step[course_practice_question_attributes][questions_attributes][0][kind]'
      within all('div[contenteditable]')[1] do
        find('p').set('Labore sanctus moderatius ex pro, cu quo amet incorrupte?')
      end
      within all('div[contenteditable]')[2] do
        find('p').set('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.')
      end
      within all('div[contenteditable]')[3] do
        find('p').set('Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.')
      end
      click_button('Save')
      expect(page).to have_content('Course Lesson Element has been created successfully')
    end

    scenario 'Create spreadsheet question standard', js: true do
      visit new_admin_course_step_path(type: 'practice_question', cm_id: course_lesson.id)
      fill_in 'course_step[course_practice_question_attributes][estimated_time]', with: '15700'
      fill_in 'course_step[name]', with: 'New Practice Question 1'
      select 'Standard', from: 'course_step_course_practice_question_attributes_kind'
      page.attach_file('Upload help file', file_path)
      fill_in 'course_step[temporary_label]', with: 'PQ1Label'
      within all('div[contenteditable]')[0] do
        find('p').set('Scenario Content 1')
      end
      fill_in 'course_step[course_practice_question_attributes][questions_attributes][0][name]', with: 'Question A'
      select 'Spreadsheet', from: 'course_step[course_practice_question_attributes][questions_attributes][0][kind]'
      within all('div[contenteditable]')[1] do
        find('p').set('Labore sanctus moderatius ex pro, cu quo amet incorrupte?')
      end
      within all('.formula-box')[0] do
        find('div').set('cupidatat non proident')
        find('div').native.send_keys(:return)
      end
      within all('.formula-box')[1] do
        find('div').set('sanctus moderatius ex pro')
        find('div').native.send_keys(:return)
      end
      click_button('Save')
      expect(page).to have_content('Course Lesson Element has been created successfully')
    end

    scenario 'Create question open type exhibit', js: true do
      visit new_admin_course_step_path(type: 'practice_question', cm_id: course_lesson.id)
      fill_in 'course_step[course_practice_question_attributes][estimated_time]', with: '15700'
      fill_in 'course_step[name]', with: 'New Practice Question 1'
      select 'Exhibit', from: 'course_step_course_practice_question_attributes_kind'
      page.attach_file('Upload help file', file_path)
      fill_in 'course_step[temporary_label]', with: 'PQ1Label'
      within all('div[contenteditable]')[0] do
        find('p').set('Scenario Content 1')
      end
      fill_in 'course_step[course_practice_question_attributes][questions_attributes][0][name]', with: 'Question A'
      select 'Open', from: 'course_step[course_practice_question_attributes][questions_attributes][0][kind]'
      within all('div[contenteditable]')[1] do
        find('p').set('Labore sanctus moderatius ex pro, cu quo amet incorrupte?')
      end
      within all('div[contenteditable]')[2] do
        find('p').set('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.')
      end
      within all('div[contenteditable]')[3] do
        find('p').set('Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.')
      end
      click_button('Save')
      expect(page).to have_content('Course Lesson Element has been created successfully')
      click_link('Manage Exhibits')
      click_link('New Exhibit')
      fill_in 'practice_question_exhibit[name]', with: 'Open Exhibit 1'
      select 'Open', from: 'practice_question_exhibit[kind]'
      find('div[contenteditable]').set('Lobortis mattis aliquam faucibus purus in. Sit amet massa vitae tortor condimentum lacinia quis.')
      click_button('Save Exhibit')
      expect(page).to have_content('Exhibit succesfully created')
      expect(page).to have_content('Open Exhibit 1')
      click_link('New Exhibit')
      fill_in 'practice_question_exhibit[name]', with: 'Spreadsheet Exhibit 1'
      select 'Spreadsheet', from: 'practice_question_exhibit[kind]'
      within('.formula-box') do
        find('div').set('condimentum lacinia quis')
        find('div').native.send_keys(:return)
      end
      click_button('Save Exhibit')
      expect(page).to have_content('Exhibit succesfully created')
      expect(page).to have_content('Spreadsheet Exhibit 1')
      click_link('New Exhibit')
      fill_in 'practice_question_exhibit[name]', with: 'Document Exhibit 1'
      select 'Document', from: 'practice_question_exhibit[kind]'
      page.attach_file('Upload help file', file_path)
      click_button('Save Exhibit')
      expect(page).to have_content('Exhibit succesfully created')
      expect(page).to have_content('Document Exhibit 1')
      click_link('Go Back')
      click_link('Manage Solutions')
      click_link('New Solution')
      fill_in 'practice_question_solution[name]', with: 'Open Solution 1'
      select 'Open', from: 'practice_question_solution[kind]'
      find('div[contenteditable]').set('Rhoncus dolor purus non enim praesent elementum facilisis leo vel.')
      click_button('Save Solution')
      expect(page).to have_content('Solution successfully created')
      expect(page).to have_content('Open Solution 1')
      click_link('New Solution')
      fill_in 'practice_question_solution[name]', with: 'Spreadsheet Solution 1'
      select 'Spreadsheet', from: 'practice_question_solution[kind]'
      within('.formula-box') do
        find('div').set('orci sagittis eu volutpat')
        find('div').native.send_keys(:return)
      end
      click_button('Save Solution')
      expect(page).to have_content('Solution successfully created')
      expect(page).to have_content('Spreadsheet Solution 1')
    end

    scenario 'Edit open question type standard', js: true do
      visit edit_admin_course_step_path(id: course_step.id)
      fill_in 'course_step[course_practice_question_attributes][questions_attributes][0][name]', with: 'Edited Question A'
      fill_in 'course_step[name]', with: 'Edited Course Step 1'
      within all('div[contenteditable]')[1] do
        find('p').set('Edited Question Content A')
      end
      within all('.note-editing-area')[2] do
        find('div.note-editable').set('cupidatat non proident')
        find('div.note-editable').native.send_keys(:return)
      end
      sleep(2)
      within all('.note-editing-area')[3] do
        find('div.note-editable').set('sanctus moderatius ex pro')
        find('div.note-editable').native.send_keys(:return)
      end
      all(:button, 'Update Question').first.click
      sleep(1)
      expect(page).to have_content('Course Lesson Element details have been updated successfully')
    end

    scenario 'Edit spreadsheet question type standard', js: true do
      visit edit_admin_course_step_path(id: course_step.id)
      fill_in 'course_step[course_practice_question_attributes][questions_attributes][0][name]', with: 'Edited Question B'
      fill_in 'course_step[name]', with: 'Edited Course Step 2'
      within all('div[contenteditable]')[1] do
        find('p').set('Edited Question Content B')
      end
      within all('.formula-box')[0] do
        find('div').set('cupidatat non proident')
        find('div').native.send_keys(:return)
      end
      within all('.formula-box')[1] do
        find('div').set('sanctus moderatius ex pro')
        find('div').native.send_keys(:return)
      end
      all(:button, 'Update Question').last.click
      sleep(1)
      expect(page).to have_content('Course Lesson Element details have been updated successfully')
    end

    scenario 'Edit open question type exhibit', js: true do
      visit edit_admin_course_step_path(id: course_step_exh.id)
      fill_in 'course_step[course_practice_question_attributes][questions_attributes][0][name]', with: 'Edited Exhibit Question A'
      fill_in 'course_step[name]', with: 'Edited Course Step 1'
      within all('div[contenteditable]')[1] do
        find('p').set('Edited Exhibit Question Content A')
      end
      within all('.note-editing-area')[2] do
        find('div.note-editable').set('cupidatat non proident')
        find('div.note-editable').native.send_keys(:return)
      end
      sleep(2)
      within all('.note-editing-area')[3] do
        find('div.note-editable').set('sanctus moderatius ex pro')
        find('div.note-editable').native.send_keys(:return)
      end
      click_link('Manage Exhibits')
      click_link('New Exhibit')
      fill_in 'practice_question_exhibit[name]', with: 'Open Exhibit 1 (edited)'
      select 'Open', from: 'practice_question_exhibit[kind]'
      find('div[contenteditable]').set('Edited open exhibit')
      click_button('Save Exhibit')
      expect(page).to have_content('Exhibit succesfully created')
      click_link('Go Back')
      click_link('Manage Solutions')
      click_link('New Solution')
      fill_in 'practice_question_solution[name]', with: 'Open Solution 1 (edited)'
      select 'Open', from: 'practice_question_solution[kind]'
      find('div[contenteditable]').set('Edited open solution')
      click_button('Save Solution')
      expect(page).to have_content('Solution successfully created')
      click_link('Go Back')
      all(:button, 'Update Question').first.click
      sleep(1)
      expect(page).to have_content('Course Lesson Element details have been updated successfully')
    end

    scenario 'Edit spreadsheet question type exhibit', js: true do
      visit edit_admin_course_step_path(id: course_step_exh.id)
      fill_in 'course_step[course_practice_question_attributes][questions_attributes][0][name]', with: 'Edited Exhibit Question B'
      fill_in 'course_step[name]', with: 'Edited Course Step 2'
      within all('div[contenteditable]')[1] do
        find('p').set('Edited Exhibit Question Content B')
      end
      within all('.formula-box')[0] do
        find('div').set('cupidatat non proident')
        find('div').native.send_keys(:return)
      end
      within all('.formula-box')[1] do
        find('div').set('sanctus moderatius ex pro')
        find('div').native.send_keys(:return)
      end
      click_link('Manage Exhibits')
      click_link('New Exhibit')
      fill_in 'practice_question_exhibit[name]', with: 'Open Exhibit 1 (edited)'
      select 'Open', from: 'practice_question_exhibit[kind]'
      find('div[contenteditable]').set('Edited open exhibit')
      click_button('Save Exhibit')
      expect(page).to have_content('Exhibit succesfully created')
      click_link('Go Back')
      click_link('Manage Solutions')
      click_link('New Solution')
      fill_in 'practice_question_solution[name]', with: 'Open Solution 1 (edited)'
      select 'Open', from: 'practice_question_solution[kind]'
      find('div[contenteditable]').set('Edited open solution')
      click_button('Save Solution')
      expect(page).to have_content('Solution successfully created')
      click_link('Go Back')
      all(:button, 'Update Question').last.click
      sleep(1)
      expect(page).to have_content('Course Lesson Element details have been updated successfully')
    end
  end
end
