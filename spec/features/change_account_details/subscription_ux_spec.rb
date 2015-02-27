require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'

describe 'Subscription UX:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup' # starts StripeMock up for us.

  let!(:subscription_1) { FactoryGirl.create(:subscription,
                          user_id: individual_student_user.id,
                          subscription_plan_id: subscription_plan_eur_m.id,
                          stripe_token: stripe_helper.generate_card_token) }
  let!(:subscription_2) { FactoryGirl.create(:subscription,
                          user_id: corporate_customer_user.id,
                          subscription_plan_id: subscription_plan_eur_m.id,
                          stripe_token: stripe_helper.generate_card_token) }

  #before { StripeMock.start }
  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
  end

  scenario 'user can upgrade subscription', js: true do
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

  scenario 'user can cancel subscription', js: true do
    user_list.each do |this_user|
      sign_in_via_sign_in_page(this_user)
      visit_my_profile
      if this_user.individual_student? || this_user.corporate_customer?
        expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
        click_link('Subscriptions')

        click_link(I18n.t('views.users.show.cancel_your_subscription_plan'))
        page.driver.browser.switch_to.alert.dismiss

        click_link(I18n.t('views.users.show.cancel_your_subscription_plan'))
        page.driver.browser.switch_to.alert.accept

        expect(page).to have_content I18n.t('views.users.show.tabs.subscriptions')
      else
        expect(page).not_to have_content I18n.t('views.users.show.tabs.subscriptions')
      end
      sign_out
      print '>'
    end
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

