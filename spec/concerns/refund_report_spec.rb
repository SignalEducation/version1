# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'refund_report' do
  before do
    allow_any_instance_of(Refund).to receive(:create_on_stripe).and_return(true)
    allow_any_instance_of(StripeApiEvent).to receive(:sync_data_from_stripe).and_return(true)
    allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
    allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)
    allow_any_instance_of(Invoice).to receive(:hubspot_get_contact).and_return(nil)
  end

  let(:obj) { create(:refund) }

  describe 'Methods used to build the refund csv' do
    Timecop.freeze(Time.zone.local(2020, 7, 1, 15, 0, 0)) do
      it { expect(obj.refunded_on).to eq(obj.created_at.strftime('%Y-%m-%d')) }
      it { expect(obj.inv_created).to eq(obj.invoice.created_at.strftime('%Y-%m-%d')) }
      it { expect(obj.sub_created).to eq(obj.subscription&.created_at.strftime('%Y-%m-%d')) }
      it { expect(obj.user_created).to eq(obj.user.created_at.strftime('%Y-%m-%d')) }
      it { expect(obj.sub_created).to eq(obj.subscription&.created_at&.strftime('%Y-%m-%d')) }
    end
    it { expect(obj.refund_id).to eq(obj&.id) }
    it { expect(obj.refund_status).to eq(obj.status) }
    it { expect(obj.stripe_id).to eq(obj.stripe_guid) }
    it { expect(obj.refund_amount).to eq(obj.amount) }
    it { expect(obj.inv_total).to eq(obj.invoice.total) }
    it { expect(obj.invoice_id).to eq(obj.invoice.id) }
    it { expect(obj.invoice_type).to eq('New') }
    it { expect(obj.email).to eq(obj.user.email) }
    it { expect(obj.sub_exam_body).to eq(obj.subscription&.subscription_plan&.exam_body&.name) }
    it { expect(obj.sub_status).to eq(obj.subscription&.state) }
    it { expect(obj.sub_type).to eq(obj.subscription&.kind) }
    it { expect(obj.payment_provider).to eq(obj.subscription&.subscription_type) }
    it { expect(obj.sub_stripe_guid).to eq(obj.subscription&.stripe_guid) }
    it { expect(obj.sub_paypal_guid).to eq(obj.subscription&.paypal_subscription_guid) }
    it { expect(obj.payment_interval).to eq(obj.subscription.subscription_plan.payment_frequency_in_months) }
    it { expect(obj.plan_name).to eq(obj.subscription.subscription_plan.name) }
    it { expect(obj.currency_symbol).to eq(obj.subscription.subscription_plan.currency.iso_code) }
    it { expect(obj.plan_price).to eq(obj.subscription.subscription_plan.price) }
    it { expect(obj.card_country).to eq(obj.user&.subscription_payment_cards&.all_default_cards&.first&.account_country) }
    it { expect(obj.user_country).to eq(obj.user&.country&.name) }
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
  end
end
