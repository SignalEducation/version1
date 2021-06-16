# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Correct Exercise', type: :feature do

  describe 'Admin can access the list of Exercises' do
    let(:user)       { build(:user) }
    let(:file_path)  { Rails.root.join('spec/fixtures/test_exercise_submission.pdf') }
    let!(:exercise)  { create(:exercise, :submission_uploaded, state: 'correcting') }
    let!(:corrector) { create(:exercise_corrections_user) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)

      visit edit_admin_exercise_path(id: exercise.id)
    end

    scenario 'Admin can see a list of submitted(default) exercises.' do
      expect(page).to have_content('Submit Corrections')
      expect(page).to have_content('Upload a replacement submission')
      expect(page).to have_selector(:link_or_button, I18n.t('views.general.save'))
      expect(page).to have_content(I18n.t('views.general.cancel'))
      expect(page).to have_content(exercise.submission_file_name)
    end

    scenario 'Admin can submit a correcton to a exercise.' do
      page.attach_file('Upload a correction', file_path)

      click_button I18n.t('views.general.save')

      expect(page).to have_content(I18n.t('controllers.exercises.update.flash.success'))
      expect(page).to have_current_path(admin_exercises_path)
    end
  end
end
