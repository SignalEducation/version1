# frozen_string_literal: true

require 'rails_helper'

describe 'Register in process', type: :feature do
  let(:user_group) { create(:student_user_group) }
  let(:student)    { create(:basic_student, :with_group, user_group: user_group) }
  let!(:new_user)  { build(:basic_student, :with_group, user_group: user_group) }

  before :each do
    activate_authlogic
    visit new_student_path
  end

  context 'User visits the register page' do
    scenario 'Loading the register page' do
      expect(page).to have_title('Free Basic Plan Registration | LearnSignal')
      expect(page).to have_content('Get Started')
      expect(page).to have_content('Registration Details')

      within('#new_user') do
        expect(page).to have_selector(:link_or_button, 'Register Now')
      end
    end
  end

  context 'User register attempt actions' do
    scenario 'valid user data' do
      expect_any_instance_of(User).to receive(:create_stripe_customer).and_return(true)

      within('#new_user') do
        fill_in I18n.t('views.users.form.first_name'), with: new_user.first_name
        fill_in I18n.t('views.users.form.last_name'), with: new_user.last_name
        fill_in I18n.t('views.users.form.email'), with: new_user.email
        fill_in I18n.t('views.users.form.first_name'), with: new_user.first_name
        fill_in I18n.t('views.users.form.password'), with: 'pass1234'
        fill_in I18n.t('views.users.form.password_confirmation'), with: 'pass1234'
        all('#user_exam_body option')[1].select_option
        hidden_field = find_field('hidden_term_and_conditions', type: :hidden)
        hidden_field.set(true)
        find('label[for=terms_and_conditions]').click
        find('label[for=communication_approval]').click

        click_button 'Register Now'
      end

      expect(page).to have_title('Dashboard')
      expect(page).to have_content('Please verify your email within 7 days to continue free tier subscription.')
      expect(page).to have_content('Check your inbox')
    end

    scenario 'invalid user data' do
      within('#new_user') do
        fill_in I18n.t('views.users.form.first_name'), with: student.first_name
        fill_in I18n.t('views.users.form.last_name'), with: student.last_name
        fill_in I18n.t('views.users.form.email'), with: student.email
        fill_in I18n.t('views.users.form.first_name'), with: student.first_name
        fill_in I18n.t('views.users.form.password'), with: 'pass1234'
        fill_in I18n.t('views.users.form.password_confirmation'), with: 'pass1234'
        all('#user_exam_body option')[1].select_option
        find('label[for=terms_and_conditions]').click
        find('label[for=communication_approval]').click

        click_button 'Register Now'
      end
      expect(page).to have_title('Free Basic Plan Registration | LearnSignal')
      expect(page).to have_content('Email has already been taken')
    end
  end
end
