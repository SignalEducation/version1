# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit a CBE', type: :feature do
  describe 'Admin can edit a CBE' do
    let(:user)            { build(:user) }
    let(:courses)         { create_list(:active_course, 5) }
    let(:cbe)             { create(:cbe, course: courses.sample) }
    let(:new_cbe)         { build(:cbe) }
    let(:cbe_section)     { create(:cbe_section, cbe: cbe) }
    let!(:cbe_question)   { create(:cbe_question, section: cbe_section) }
    let(:new_cbe_section) { build(:cbe_section) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)

      visit admin_cbe_path(id: cbe.id)
    end

    describe 'Edit CBE form', js: true do
      it 'Edit a CBE' do
        # Section
        click_link cbe_section.name
        click_button 'Edit Section'

        expect(page).to have_content(cbe_section.name)
        expect(page).to have_content(cbe_section.score)

        fill_in 'sectionName', with: new_cbe_section.name
        fill_in 'sectionScore', with: new_cbe_section.score

        within_frame('sectionEditor1_ifr') do
          editor = page.find_by_id('tinymce')
          editor.native.send_keys new_cbe_section.content
        end

        click_button 'Update Section'
        sleep(2)
        click_button 'Edit Section'

        # Details
        click_button 'CBE Details'

        select courses.sample.name, from: 'subjectCoursesSelect'
        fill_in 'cbeName', with: new_cbe.name

        click_button 'Update CBE'

        # Refresh page to see udpated info.
        visit current_path
        sleep(2)

        expect(page).to have_content(new_cbe_section.name)

        click_button 'CBE Details'
        sleep(2)

        expect(find_field('cbeName').value).to eq new_cbe.name
      end
    end
  end
end
