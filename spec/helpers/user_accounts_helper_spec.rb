# frozen_string_literal: true

require 'rails_helper'

describe UserAccountsHelper, type: :helper do
  let (:subscription_01) { build(:subscription, subscription_plan_id: nil) }
  let (:subscription_02) { build(:subscription, next_renewal_date: nil, subscription_plan_id: nil) }

  describe '#account_cancellation_message' do
    context 'with next renewal date' do
      it 'remote link' do
        expect(helper.account_cancellation_message(subscription_01)).to eq("Cancellation will be effective at the end of your current billing periodon #{helper.humanize_stripe_date_full(subscription_01.next_renewal_date)} and you will then lose access to all the benefits shown above.")
      end
    end
    context 'without next renewal date' do
      it 'remote link' do
        expect(account_cancellation_message(subscription_02)).to eq('Cancellation will be effective at the end of your current billing period')
      end
    end
  end
end
