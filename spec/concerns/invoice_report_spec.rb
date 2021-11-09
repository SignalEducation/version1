# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'invoice_report' do
  before do
    allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
    allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)
  end

  let(:user)         { create(:user) }
  let(:subscription) { create(:subscription, user: user) }
  let(:obj)          { create(:invoice, user: user, subscription: subscription) }

  describe 'Methods used to build the invoice csv' do
    it { expect(obj.inv_id).to eq(obj.id) }
    it { expect(obj.user_email).to eq(obj.user.email) }
    Timecop.freeze(Time.zone.local(2020, 7, 1, 15, 0, 0)) do
      it { expect(obj.invoice_created).to eq(obj.created_at.strftime('%Y-%m-%d')) }
      it { expect(obj.user_created).to eq(obj.user.created_at.strftime('%Y-%m-%d')) }
      it { expect(obj.sub_created).to eq(obj.subscription&.created_at.strftime('%Y-%m-%d')) }
    end
    it { expect(obj.sub_exam_body).to eq(obj.subscription&.subscription_plan&.exam_body&.name) }
    it { expect(obj.sub_status).to eq(obj.subscription&.state) }
    it { expect(obj.sub_type).to eq(obj.subscription&.kind) }
    it { expect(obj.payment_provider).to eq(obj.subscription&.subscription_type) }
    it { expect(obj.invoice_type).to eq('New') }
    it { expect(obj.sub_stripe_guid).to eq(obj.subscription&.stripe_guid) }
    it { expect(obj.sub_paypal_guid).to eq(obj.subscription&.paypal_subscription_guid) }
    it { expect(obj.payment_interval).to eq(obj.subscription.subscription_plan.payment_frequency_in_months) }
    it { expect(obj.plan_name).to eq(obj.subscription.subscription_plan.name) }
    it { expect(obj.currency_symbol).to eq(obj.subscription.subscription_plan.currency.iso_code) }
    it { expect(obj.plan_price).to eq(obj.subscription.subscription_plan.price) }
    it { expect(obj.card_country).to eq(obj.user&.subscription_payment_cards.all_default_cards&.first&.account_country) }
    it { expect(obj.user_country).to eq(obj.user&.country&.iso_code) }
    it { expect(obj.first_visit).to eq(obj.user.ahoy_visits.order(:started_at)&.first) }
    it { expect(obj.first_visit_date).to eq('') }
    it { expect(obj.first_visit_landing_page).to eq('') }
    it { expect(obj.first_visit_referrer).to eq('') }
    it { expect(obj.first_visit_referring_domain).to eq('') }
    it { expect(obj.first_visit_source).to eq('') }
    it { expect(obj.first_visit_medium).to eq('') }
    it { expect(obj.first_visit_search_keyword).to eq('') }
    it { expect(obj.first_visit_country).to eq('') }
    it { expect(obj.first_visit_utm_campaign).to eq('') }
    it { expect(obj.coupon_code).to eq(obj.subscription&.coupon&.code) }
    it { expect(obj.coupon_id).to eq(obj.subscription&.coupon&.id) }
  end
end
