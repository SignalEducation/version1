# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_line_items
#
#  id                   :integer          not null, primary key
#  invoice_id           :integer
#  amount               :decimal(, )
#  currency_id          :integer
#  prorated             :boolean
#  period_start_at      :datetime
#  period_end_at        :datetime
#  subscription_id      :integer
#  subscription_plan_id :integer
#  original_stripe_data :text
#  created_at           :datetime
#  updated_at           :datetime
#

require 'rails_helper'

describe InvoiceLineItem, type: :model do
  let(:currency)               { create(:currency) }
  let(:invoice)                { create(:invoice, currency: currency) }
  let(:invoice_line_item)      { build(:invoice_line_item) }
  let(:subscription_plan)      { build(:subscription_plan) }
  let(:invoice_line_item_data) {
    JSON.parse(file_fixture('stripe/invoice_line_item.json').read).with_indifferent_access
  }

  # relationships
  it { should belong_to(:invoice) }
  it { should belong_to(:currency) }
  it { should belong_to(:subscription) }
  it { should belong_to(:subscription_plan) }

  # validation
  it { should validate_presence_of(:invoice_id) }
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:currency_id) }
  ## validation of subscription invoice
  before { allow(subject).to receive(:subscription_invoice?).and_return(true) }
  it { should validate_presence_of(:subscription_id) }
  it { should validate_presence_of(:subscription_plan_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(InvoiceLineItem).to respond_to(:all_in_order) }

  describe '#methods' do
    context '.build_from_stripe_data' do
      it 'save invoice line item' do
        allow(Currency).to receive(:find_by).and_return(currency)
        allow(SubscriptionPlan).to receive(:find_by).and_return(subscription_plan)

        expect(InvoiceLineItem.build_from_stripe_data(1, invoice_line_item_data, 1)).to be(true)
      end
    end

    context '.build_from_paypal_data' do
      it 'save invoice line item' do
        allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
        allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)

        expect(InvoiceLineItem.build_from_paypal_data(invoice)).to be_kind_of(InvoiceLineItem)
      end
    end

    context '#destroyable?' do
      it 'always return true' do
        allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
        allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)

        expect(invoice_line_item).to be_destroyable
      end
    end

    context '#check_dependencies' do
      it 'stubb destroyable to tru to cover method' do
        allow_any_instance_of(InvoiceLineItem).to receive(:destroyable?).and_return(false)
        allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
        allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)
        invoice_line_item.destroy

        expect(invoice_line_item.errors).not_to be_empty
      end
    end
  end
end
