require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'

describe 'Subscription UX:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup' # starts StripeMock up for us.

  let!(:subscription_1) { x = FactoryGirl.create(:subscription,
                          user_id: individual_student_user.id,
                          subscription_plan_id: subscription_plan_eur_m.id,
                          stripe_token: stripe_helper.generate_card_token)
                          individual_student_user.update_attribute(:stripe_customer_id, x.stripe_customer_id)
                          x }
  let!(:subscription_2) { x = FactoryGirl.create(:subscription,
                          user_id: corporate_customer_user.id,
                          subscription_plan_id: subscription_plan_eur_m.id,
                          stripe_token: stripe_helper.generate_card_token)
                          corporate_customer_user.update_attribute(:stripe_customer_id, x.stripe_customer_id)
                          x }
  #before { StripeMock.start }
  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
  end

  scenario 'user can upgrade a subscription', js: true do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      if this_user.individual_student? || this_user.corporate_customer?
        expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
        click_link(I18n.t('views.users.show.tabs.subscriptions'))
        expect(page).to have_content I18n.t('views.users.show.your_plans_current_status')

        2.times do
          click_link(I18n.t('views.users.show.upgrade_subscription_plan'))
          expect(page).to have_content maybe_upcase I18n.t('views.users.show.upgrade_subscription_plan')
          upgrade_options = this_user.subscriptions.all_in_order.last.upgrade_options
          check_that_the_plans_are_visible(upgrade_options)

          find("#subscription-panel-#{upgrade_options[1].id}").click
          expect(find('#subscription_subscription_plan_id', visible: false).value.to_i).to eq(upgrade_options[1].id)
          click_button(I18n.t('views.users.show.upgrade_now'))

          # page should reload
          expect(page).to have_content(I18n.t('controllers.subscriptions.update.flash.success'))
        end

        # upgraded twice; now we can't upgrade anymore
        expect(page).to have_content I18n.t('views.users.show.no_upgrade_options_available')

      else
        expect(page).not_to have_content I18n.t('views.users.show.tabs.subscriptions')
      end

      sign_out
      print '>'
    end
  end

  scenario 'user can cancel and reactivate a subscription', js: true do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      if this_user.individual_student? || this_user.corporate_customer?
        expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
        click_link('Subscriptions')
        cancel_and_un_cancel_a_trial_account
      else
        expect(page).not_to have_content I18n.t('views.users.show.tabs.subscriptions')
      end
      sign_out
      print '>'
    end
  end

  scenario 'student_user can un-cancel a canceled-pending subscription', js: :true do
    # sign up as a student
    visit root_path
    click_link I18n.t('views.general.sign_up')
    expect(page).to have_content maybe_upcase I18n.t('views.student_sign_ups.new.h1')
    student_sign_up_as('Dan', 'Murphy', nil, 'valid', eur, ireland, 1, true)

    # go to my-profile page
    visit_my_profile
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_link('Subscriptions')

    # cancel the trial account and reactivate it as an 'active'
    cancel_and_un_cancel_a_trial_account

    # cancel the current (active) subscription
    click_link(I18n.t('views.users.show.cancel_your_subscription_plan'))
    page.driver.browser.switch_to.alert.accept
    sleep 5
    expect(page).to have_content 'canceled-pending'

    # un-cancel it
    click_link(I18n.t('views.users.show.un_cancel_subscription.button_call_to_action'))

    # happy ending
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    expect(page).to have_content 'active'

    sign_out
  end

  scenario 'student_user can view invoices', js: true do
    # sign up as a student
    visit root_path
    click_link I18n.t('views.general.sign_up')
    expect(page).to have_content maybe_upcase I18n.t('views.student_sign_ups.new.h1')
    student_sign_up_as('Dan', 'Murphy', nil, 'valid', eur, ireland, 1, true)

    # go to my-profile page
    visit_my_profile
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_link('Subscriptions')

    expect(page).to have_content maybe_upcase I18n.t('views.users.show.your_invoices')

    within('#invoices-panel') do
      expect(page).not_to have_content(I18n.t('views.invoices.index.print'))
      click_link('Refresh')
      expect(page).to have_css('#invoices-table')
      expect(page).to have_content(I18n.t('views.invoices.index.print'))
      click_link(I18n.t('views.invoices.index.print'))
    end

    # on the print page
    expect(page).to have_css('.glyphicon-print')
    click_link(I18n.t('views.users.show.h1'))
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')

    sign_out
  end

  scenario 'user can update card details', js: true do
    # sign up as a student
    visit root_path
    click_link I18n.t('views.general.sign_up')
    expect(page).to have_content maybe_upcase I18n.t('views.student_sign_ups.new.h1')
    student_sign_up_as('Dan', 'Murphy', nil, 'valid', eur, ireland, 1, true)

    # go to my-profile page
    visit_my_profile
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_link('Subscriptions')

    expect(page).to have_content maybe_upcase I18n.t('views.users.show.your_card_details')
    expect(page).not_to have_css('#new-subscription-payment-card-modal')

    within('#credit-cards-panel') do
      click_link('Refresh')
    end

    # omitted:
    # - bad_number: can't get off the Modal
    # - valid: already on file
    %w(expired bad_cvc declined processing_error valid_visa_debit
valid_mc_debit).each do |this_card|
      within('#credit-cards-panel') do
        expect(page).to have_css('#cards-table')
        click_link(I18n.t('views.users.show.add_new_card'))
      end

      # new card modal
      expect(page).to have_css('#new-subscription-payment-card-modal')
      sleep 1
      enter_credit_card_details(this_card)
      click_button(I18n.t('views.general.save'))
      sleep 1

      # back at the subscriptions page
      if this_card.include?('valid')
        expect(page).to have_content I18n.t('controllers.subscription_payment_cards.create.flash.success')
        expect(page).not_to have_content I18n.t('controllers.subscription_payment_cards.create.flash.error')
      else
        expect(page).not_to have_content I18n.t('controllers.subscription_payment_cards.create.flash.success')
        expect(page).to have_content I18n.t('controllers.subscription_payment_cards.create.flash.error')
      end
    end

    # There are now three cards on file. Select an alternate to be the default
    %w(4242 5556 8210).each do |last4|
      within('#credit-cards-panel') do
        within("#card-#{last4}") do # Visa Debit
          expect(page).not_to have_css('.label-success')
          click_link(I18n.t('views.users.show.use_this_card'))
          expect(page).to have_css('.label-success')
        end
      end
    end

    sleep 5
    sign_out
  end

  def cancel_and_un_cancel_a_trial_account
    click_link(I18n.t('views.users.show.cancel_your_subscription_plan'))
    page.driver.browser.switch_to.alert.dismiss

    click_link(I18n.t('views.users.show.cancel_your_subscription_plan'))
    page.driver.browser.switch_to.alert.accept

    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    expect(page).to have_content maybe_upcase I18n.t('views.users.show.reactivate_subscription.h3')
    click_link(I18n.t('views.users.show.reactivate_subscription.button_call_to_action'))

    # inside the reactivation modal
    within('#re-subscribe-modal') do
      click_button(I18n.t('views.users.show.upgrade_now'))
    end
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    expect(page).to have_content 'active'
  end

  def check_that_the_plans_are_visible(plans)
    expect(plans.size).to be > 1
    expect(plans.size).to be <= 3
    plans.each do |option|
      expect(page).to have_content maybe_upcase option.name
      option.description.lines.each do |line|
        expect(page).to have_content line
      end
    end
  end

end

