# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'List Exercises', type: :feature do
  include ExercisesHelper

  describe 'Admin can access the list of Exercises' do
    let(:user)                 { build(:user) }
    let!(:pending_exercises)   { create_list(:exercise, 5, state: 'pending') }
    let!(:submitted_exercises) { create_list(:exercise, 5, state: 'submitted') }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)

      visit admin_exercises_path
    end

    scenario 'Admin can see a list of submitted(default) exercises.' do
      expect(page).to have_content(I18n.t('views.exercises.admin.index.name'))
      expect(page).to have_content(I18n.t('views.exercises.admin.index.email'))
      expect(page).to have_content(I18n.t('views.exercises.admin.index.product'))
      expect(page).to have_content(I18n.t('views.exercises.admin.index.state'))
      expect(page).to have_content(I18n.t('views.exercises.admin.index.due_on'))
      expect(page).to have_content(I18n.t('views.exercises.admin.index.corrected_on'))
      expect(page).to have_content(I18n.t('views.exercises.admin.index.returned_on'))

      expect(page).to have_content(submitted_exercises.sample.user.name)
      expect(page).to have_content(submitted_exercises.sample.user.email)
      expect(page).to have_content(submitted_exercises.sample.product.name)
      expect(page).to have_content(submitted_exercises.sample.state)
      expect(page).to have_content(exercise_due_date(submitted_exercises.sample))
    end

    scenario 'Admin can see links actions.' do
      within('div.search-container') do
        expect(page).to have_select('state', options: %w[Submitted Correcting Returned Pending All])
        expect(page).to have_select('product', options: Product.all_active.map(&:name) << 'All Products')
        expect(page).to have_select('corrector', options: ['All Correctors'])
        expect(page).to have_selector("input[name='search']")
        expect(page).to have_selector(:link_or_button)
      end

      expect(page).to have_selector(:link_or_button, I18n.t('views.general.edit'))
      expect(page).to have_selector(:link_or_button, 'Claim')
      expect(page).to have_selector(:link_or_button, 'Generate Daily Summary')
      expect(page).to have_selector(:link_or_button, 'Bulk Assign Exercises')
    end

    scenario 'Admin select pending exercises.' do
      within('div.search-container') do
        select 'Pending', from: 'state'
        click_button
      end

      expect(page).to have_content(pending_exercises.sample.user.name)
      expect(page).to have_content(pending_exercises.sample.user.email)
      expect(page).to have_content(pending_exercises.sample.product.name)
      expect(page).to have_content(pending_exercises.sample.state)
      expect(page).to have_content(exercise_due_date(pending_exercises.sample))
    end

    scenario 'Admin select a specific product.' do
      exercise = pending_exercises.sample

      within('div.search-container') do
        select 'Pending', from: 'state'
        select exercise.product.name, from: 'product'
        click_button
      end

      expect(page).to have_content(exercise.user.name)
      expect(page).to have_content(exercise.user.email)
      expect(page).to have_content(exercise.product.name)
      expect(page).to have_content(exercise.state)
      expect(page).to have_content(exercise_due_date(exercise))
    end

    scenario 'Admin search for a specific exxercise name.' do
      exercise = pending_exercises.sample

      within('div.search-container') do
        select 'Pending', from: 'state'
        fill_in 'search', with: exercise.user.name
        click_button
      end

      expect(page).to have_content(exercise.user.name)
      expect(page).to have_content(exercise.user.email)
      expect(page).to have_content(exercise.product.name)
      expect(page).to have_content(exercise.state)
      expect(page).to have_content(exercise_due_date(exercise))
    end
  end
end
