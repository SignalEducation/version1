# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'List CBEs', type: :feature do
  describe 'Admin can access the list of CBEs' do
    let(:user)               { build(:user) }
    let!(:cbe)               { create(:cbe) }
    let!(:introduction_page) { create(:cbe_introduction_page, cbe: cbe) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)

      visit admin_cbes_path
    end

    describe 'Admin can see a list of cbes.' do
      it { expect(page).to have_content('CBEs') }
      it { expect(page).to have_content('Name') }
      it { expect(page).to have_content('Course') }
      it { expect(page).to have_content('Active') }

      it { expect(page).to have_content(cbe.name) }
      it { expect(page).to have_content(cbe.course.name) }
    end

    describe 'Admin can see buttons actions.' do
      it { expect(page).to have_selector(:link_or_button, 'New CBE') }
      it { expect(page).to have_selector(:link_or_button, I18n.t('views.general.edit')) }
      it { expect(page).to have_selector(:link_or_button, I18n.t('views.general.show')) }
      it { expect(page).to have_selector(:link_or_button, I18n.t('views.general.clone')) }
    end

    describe 'Admin can click in new cbe action.', js: true do
      before { find_link('New CBE').click }

      it 'new cbe form' do
        expect(page).to have_content('CBE')
        expect(page).to have_content('Please select a course')
        expect(page).to have_content('Agreement Text')
        expect(page).to have_content('Save CB')
        expect(page).to have_selector(:link_or_button, 'Save CBE')
      end
    end

    describe 'Admin can click in the show action of a specific CBE.', js: true do
      before { find_link(I18n.t('views.general.show')).click }

      it { expect(page).to have_content(introduction_page.content) }
    end

    describe 'Admin can click in the edit action of a specific CBE.', js: true do
      before { find_link(I18n.t('views.general.edit')).click }

      it { expect(page).to have_content('Exam Content') }
    end

    describe 'Admin can click in the clone action of a specific CBE.' do
      before do
        accept_confirm { find_link(I18n.t('views.general.clone')).click }
        expect(CbeCloneWorker).to receive(:perform_async).and_return(true)
      end

      it { expect(page).to have_content('CBE is cloning now, you will receive an email when finished.') }
    end
  end
end
