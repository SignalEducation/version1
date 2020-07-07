# == Schema Information
#
# Table name: refunds
#
#  id                 :integer          not null, primary key
#  stripe_guid        :string
#  charge_id          :integer
#  stripe_charge_guid :string
#  invoice_id         :integer
#  subscription_id    :integer
#  user_id            :integer
#  manager_id         :integer
#  amount             :integer
#  reason             :text
#  status             :string
#  livemode           :boolean          default("true")
#  stripe_refund_data :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'
require 'concerns/refund_report_spec.rb'

describe Refund, type: :model do
  let(:refund) { build(:refund) }

  describe 'Should Respond' do
    it { should respond_to(:stripe_guid) }
    it { should respond_to(:charge_id) }
    it { should respond_to(:stripe_charge_guid) }
    it { should respond_to(:invoice_id) }
    it { should respond_to(:subscription_id) }
    it { should respond_to(:user_id) }
    it { should respond_to(:manager_id) }
    it { should respond_to(:amount) }
    it { should respond_to(:reason) }
    it { should respond_to(:status) }
    it { should respond_to(:livemode) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:charge) }
    it { should belong_to(:invoice) }
    it { should belong_to(:subscription) }
    it { should belong_to(:user) }
    it { should belong_to(:manager) }
  end

  describe 'Validations' do
    before do
      allow_any_instance_of(Refund).to receive(:create_on_stripe).and_return(true)
    end

    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:reason) }
    it { should validate_presence_of(:charge_id) }
    it { should validate_presence_of(:invoice_id) }
    it { should validate_presence_of(:subscription_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:manager_id) }
    it { should validate_inclusion_of(:reason).in_array(%w[duplicate fraudulent requested_by_customer]) }
    it { should validate_uniqueness_of(:stripe_guid) }
    it { should validate_numericality_of(:charge_id) }
    it { should validate_numericality_of(:invoice_id) }
    it { should validate_numericality_of(:subscription_id) }
    it { should validate_numericality_of(:user_id) }
    it { should validate_numericality_of(:manager_id) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:create_on_stripe).after(:create) }
  end

  describe 'scopes' do
    it { expect(Refund).to respond_to(:all_in_order) }
  end

  describe 'Concern' do
    it_behaves_like 'refund_report'
  end

  describe '.to_csv' do
    before do
      allow_any_instance_of(Refund).to receive(:create_on_stripe).and_return(true)
      allow_any_instance_of(StripeApiEvent).to receive(:sync_data_from_stripe).and_return(true)
      allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
      allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)
      allow_any_instance_of(Invoice).to receive(:hubspot_get_contact).and_return(nil)
    end

    let(:invoice) { create(:invoice) }
    let!(:refund) { create(:refund, invoice: invoice) }

    context 'generate csv data' do
      it { expect(Refund.all.to_csv.split(',')).to include('refund_id',
                                                           'refunded_on',
                                                           'refund_status',
                                                           'stripe_id',
                                                           'refund_amount',
                                                           'inv_total',
                                                           'inv_created',
                                                           'invoice_id',
                                                           'invoice_type',
                                                           'email',
                                                           'user_created',
                                                           'sub_created',
                                                           'sub_exam_body',
                                                           'sub_status',
                                                           'sub_type',
                                                           'payment_provider',
                                                           'sub_stripe_guid',
                                                           'sub_paypal_guid',
                                                           'payment_interval',
                                                           'plan_name',
                                                           'currency_symbol',
                                                           'plan_price',
                                                           'card_country',
                                                           'user_country',
                                                           'first_visit',
                                                           'first_visit_date',
                                                           'first_visit_landing_page',
                                                           'first_visit_referrer',
                                                           'first_visit_referring_domain',
                                                           'first_visit_source',
                                                           'first_visit_medium',
                                                           'first_visit_search_keyword',
                                                           'first_visit_country') }
    end
  end

  describe 'Instance Methods' do
    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:async_action)
      allow(Stripe::Event).to receive(:retrieve).and_return({ "payload": { "key": 1 } })
    end

    describe '#destroyable?' do
      it 'returns FALSE' do
        expect(refund.destroyable?).to eq false
      end
    end

    describe '#check_dependencies' do
      it 'returns FALSE' do
        expect(refund.send(:check_dependencies)).to eq false
      end

      it 'returns NIL if the record is NOT destroyable' do
        allow(refund).to receive(:destroyable?).and_return(true)

        expect(refund.send(:check_dependencies)).to be_nil
      end
    end

    describe '#create_on_stripe' do
      let(:stripe_refund) {
        JSON.parse(
          File.read(
            Rails.root.join('spec/fixtures/stripe/refund.json')
          )
        ).transform_keys(&:to_sym)
      }
      let!(:refund) { build(:refund, stripe_guid: nil) }

      it 'creates a refund on Stripe' do
        expect(Stripe::Refund).to receive(:create).and_return(stripe_refund)

        refund.save
      end

      it 'updates the refund record with Stripe data' do
        allow(Stripe::Refund).to receive(:create).and_return(stripe_refund)

        expect { refund.save }.to change { refund.stripe_guid }
      end

      it 'rescues from Stripe::InvalidRequestError' do
        Stripe::Refund.stub(:create) { raise Stripe::InvalidRequestError }

        expect { refund.save }.to(raise_error { Learnsignal::PaymentError })
      end
    end
  end
end
