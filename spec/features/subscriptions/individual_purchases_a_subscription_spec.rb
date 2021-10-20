# frozen_string_literal: true

require 'rails_helper'

describe 'An individual purchasing a subscription', type: :feature do
  let(:country) { create(:country, name: 'United Kingdom') }
  let!(:user_group) { create(:student_user_group) }
  let!(:exam_body) { FactoryBot.create(:exam_body) }
  let!(:group) { FactoryBot.create(:group, exam_body: exam_body) }

  before(:each) do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    create(:student_subscription_plan_m, currency: country.currency, exam_body: exam_body)
    create(:student_subscription_plan_q, currency: country.currency, exam_body: exam_body)
    create(:student_subscription_plan_y, currency: country.currency, exam_body: exam_body)
  end

  context 'as a logged-in user' do
    let(:user) { create(:user, user_group: user_group, currency: country.currency, preferred_exam_body: exam_body) }

    before(:each) do
      activate_authlogic
    end

    context 'when browsing from the pricing page' do
      scenario 'can browse available plans' do
        sign_in_via_sign_in_page(user)
        visit pricing_path(group_name_url: exam_body.group.name_url)
        expect(page).to have_content('Choose this plan')
      end

      scenario 'can choose a plan and checkout with PayPal' do
        sign_in_via_sign_in_page(user)
        visit pricing_path(group_name_url: exam_body.group.name_url)
        first(:link, 'Choose this plan').click

        expect(page).to have_content('Pay with PayPal')

        find('label[for=pay-with-paypal]').click

        expect(page).to have_selector('#paypal_submit')
      end

      scenario 'can choose a plan and checkout with Stripe' do
        sign_in_via_sign_in_page(user)
        visit pricing_path(group_name_url: exam_body.group.name_url)
        first(:link, 'Choose this plan').click

        expect(page).to have_content('Pay with Card')
        expect(page).to have_selector('#pay-with-card', visible: false)
      end

      scenario 'can switch chosen plans' do
        sign_in_via_sign_in_page(user)
        visit pricing_path(group_name_url: exam_body.group.name_url)
        first(:link, 'Choose this plan').click
        expect(page).to have_selector('#all-plans', visible: true)
      end
    end
  end
end
