# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a new CBE', type: :feature do
  describe 'Admin can create a CBE' do
    let(:user)         { build(:user) }
    let(:cbe)          { build(:cbe) }
    let(:cbe_section)  { build(:cbe_section, cbe: cbe) }
    let(:cbe_question) { build(:cbe_question, section: cbe_section) }
    let!(:courses)     { create_list(:active_course, 5) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)

      visit new_admin_cbe_path
    end

    describe 'New CBE form', js: true do
      it 'Create a CBE' do
        # Details
        select courses.sample.name, from: 'subjectCoursesSelect'
        fill_in 'cbeName', with: cbe.name

        click_button 'Save CBE'

        # Section
        fill_in 'sectionName', with: cbe_section.name
        fill_in 'sectionScore', with: cbe_section.score
        fill_in 'sortingOrder', with: 1
        select 'Objective', from: 'sectionKindSelect'

        within_frame('sectionEditornull_ifr') do
          editor = page.find_by_id('tinymce')
          editor.native.send_keys cbe_section.content
        end

        click_button 'Save Section'
        sleep(2)

        # Question
        click_link cbe_section.name

        # Dropdown list
        within('div#new-question-accordion') do
          fill_in 'questionScore', with: cbe_question.score
          select 'dropdown_list', from: 'questionKindSelect'
          sleep(1)

          within_frame('questionEditor-1-null-null_ifr') do
            editor = page.find_by_id('tinymce')
            editor.native.send_keys cbe_question.content
          end

          within_frame('questionSolution-1-null-null_ifr') do
            editor = page.find_by_id('tinymce')
            editor.native.send_keys cbe_question.solution
          end

          5.times do
            fill_in 'dropdownAnswer', with: Faker::Lorem.word
            click_button 'dropdownbtnAddAnswer'
          end

          page.choose('null-answers', match: :first)

          sleep(2)
          click_button 'Save Question'
          sleep(2)
        end

        # Fill in the blank
        within('div#new-question-accordion') do
          fill_in 'questionScore', with: cbe_question.score
          select 'fill_in_the_blank', from: 'questionKindSelect'
          sleep(1)

          within_frame('questionEditor-1-null-null_ifr') do
            editor = page.find_by_id('tinymce')
            editor.native.send_keys cbe_question.content
          end

          within_frame('questionSolution-1-null-null_ifr') do
            editor = page.find_by_id('tinymce')
            editor.native.send_keys cbe_question.solution
          end

          fill_in 'fillInTheBlankAnswer', with: Faker::Lorem.word
          sleep(2)
          click_button 'Save Question'
          sleep(2)
        end

        # Multiple Choise
        within('div#new-question-accordion') do
          fill_in 'questionScore', with: cbe_question.score
          select 'multiple_choice', from: 'questionKindSelect'
          sleep(1)

          within_frame('questionEditor-1-null-null_ifr') do
            editor = page.find_by_id('tinymce')
            editor.native.send_keys cbe_question.content
          end

          within_frame('questionSolution-1-null-null_ifr') do
            editor = page.find_by_id('tinymce')
            editor.native.send_keys cbe_question.solution
          end

          5.times do
            fill_in 'multipleChoiseAnswer', with: Faker::Lorem.word
            click_button 'multipleChoiseBtnAddAnswer'
          end

          page.choose('null-answers', match: :first)

          sleep(2)
          click_button 'Save Question'
          sleep(2)
        end

        # Multiple Response
        within('div#new-question-accordion') do
          fill_in 'questionScore', with: cbe_question.score
          select 'multiple_response', from: 'questionKindSelect'
          sleep(1)

          within_frame('questionEditor-1-null-null_ifr') do
            editor = page.find_by_id('tinymce')
            editor.native.send_keys cbe_question.content
          end

          within_frame('questionSolution-1-null-null_ifr') do
            editor = page.find_by_id('tinymce')
            editor.native.send_keys cbe_question.solution
          end

          5.times do
            fill_in 'multipleResponseAnswer', with: Faker::Lorem.word
            click_button 'multipleResponseBtnAddAnswer'
          end

          find("input[type='checkbox']", match: :first).set(true)

          sleep(2)
          click_button 'Save Question'
          sleep(2)
        end

        expect(page).to have_content('Question - 1')
        expect(page).to have_content('Question - 2')
        expect(page).to have_content('Question - 3')
        expect(page).to have_content('Question - 4')
      end
    end
  end
end
