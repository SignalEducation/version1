require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/course_content'

describe 'Subscription UX:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'
  include_context 'subscription_plans_setup' # starts StripeMock up for us.

  let!(:individual_student_user_2) { FactoryGirl.create(:individual_student_user,
                                                      user_group_id: individual_student_user_group.id) }

  let!(:subscription_1) { x = FactoryGirl.create(:subscription,
                          user_id: individual_student_user.id,
                          subscription_plan_id: subscription_plan_eur_m.id,
                          stripe_token: stripe_helper.generate_card_token)
                          individual_student_user.update_attribute(:stripe_customer_id, x.stripe_customer_id)
                          x }
  let!(:subscription_2) { x = FactoryGirl.create(:subscription,
                          user_id: individual_student_user_2.id,
                          subscription_plan_id: subscription_plan_eur_m.id,
                          stripe_token: stripe_helper.generate_card_token)
  individual_student_user_2.update_attribute(:stripe_customer_id, x.stripe_customer_id)
                          x }
  #before { StripeMock.start }
  after { StripeMock.stop }

  before(:each) do
    a = admin_user
    b = individual_student_user
    activate_authlogic
  end

  scenario 'user can upgrade a subscription', js: true do
    sign_up_and_upgrade_from_free_trial
    visit_my_profile
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_link(I18n.t('views.users.show.tabs.subscriptions'))
    click_link(I18n.t('views.users.show.change_subscription_plan'))
    expect(page).to have_content 'Select a new plan'
    parent = page.find('.plans:first-child')
    parent.click

    click_button(I18n.t('views.general.save'))
    # page should reload
    expect(page).to have_content(I18n.t('controllers.subscriptions.update.flash.success'))
    expect(page).to have_content 'Billing Interval Quarterly'
    sign_out
  end

  xit scenario 'user can cancel and reactivate a subscription', js: true do
    sign_up_and_upgrade_from_free_trial
    visit_my_profile
    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_link(I18n.t('views.users.show.tabs.subscriptions'))
    click_link(I18n.t('views.users.show.cancel_your_subscription_plan'))
    page.driver.browser.switch_to.alert.accept

    expect(page).to have_content 'Your Subscription has been cancelled'
    visit user_reactivate_account_path(user_id: User.last.id)


    student_picks_a_subscription_plan(eur, 12)
    enter_credit_card_details('valid')
    check I18n.t('views.general.terms_and_conditions')
    find('.upgrade-sub').click
    sleep(10)
    expect(page).to have_content 'Thanks for upgrading your subscription!'
    visit_my_profile
    click_on I18n.t('views.users.show.tabs.subscriptions')

    sign_out
  end

  scenario 'student_user can view invoices', js: true do
    # sign up as a student
    sign_up_and_upgrade_from_free_trial
    visit_my_profile

    expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
    click_link(I18n.t('views.users.show.tabs.subscriptions'))

    expect(page).to have_content maybe_upcase I18n.t('views.users.show.your_invoices')

    sign_out
  end

  scenario 'user can update card details', js: true do
    # sign up as a student
    sign_up_and_upgrade_from_free_trial
    visit_my_profile
    expect(page).to have_content I18n.t('views.users.show.tabs.payments')
    click_on I18n.t('views.users.show.tabs.payments')

    within('#add-card') do
      find('.add-card').click
    end

    within('#new-subscription-payment-card-form') do
      %w(valid_visa_debit ).each do |this_card|
        sleep 2
        #click_link(I18n.t('views.users.show.tabs.payments'))
        # new card modal
        #sleep 2
        enter_credit_card_details(this_card)
        click_button(I18n.t('views.general.save'))
        sleep 2

        # back at the subscriptions page
        if this_card.include?('valid')
          sleep(1)
          expect(page).to have_content I18n.t('controllers.subscription_payment_cards.create.flash.success')
          expect(page).not_to have_content I18n.t('controllers.subscription_payment_cards.create.flash.error')
        else
          expect(page).not_to have_content I18n.t('controllers.subscription_payment_cards.create.flash.success')
          expect(page).to have_content I18n.t('controllers.subscription_payment_cards.create.flash.error')
        end
      end

    end


    sign_out
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
  sleep(10)
end

