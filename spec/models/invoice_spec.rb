# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  subscription_transaction_id :integer
#  subscription_id             :integer
#  number_of_users             :integer
#  currency_id                 :integer
#  vat_rate_id                 :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  issued_at                   :datetime
#  stripe_guid                 :string(255)
#  sub_total                   :decimal(, )      default("0")
#  total                       :decimal(, )      default("0")
#  total_tax                   :decimal(, )      default("0")
#  stripe_customer_guid        :string(255)
#  object_type                 :string(255)      default("invoice")
#  payment_attempted           :boolean          default("false")
#  payment_closed              :boolean          default("false")
#  forgiven                    :boolean          default("false")
#  paid                        :boolean          default("false")
#  livemode                    :boolean          default("false")
#  attempt_count               :integer          default("0")
#  amount_due                  :decimal(, )      default("0")
#  next_payment_attempt_at     :datetime
#  webhooks_delivered_at       :datetime
#  charge_guid                 :string(255)
#  subscription_guid           :string(255)
#  tax_percent                 :decimal(, )
#  tax                         :decimal(, )
#  original_stripe_data        :text
#  paypal_payment_guid         :string
#  order_id                    :bigint
#  requires_3d_secure          :boolean          default("false")
#  sca_verification_guid       :string
#

require 'rails_helper'
require 'concerns/invoice_report_spec.rb'

describe Invoice do
  before :each do
    allow_any_instance_of(StripePlanService).to receive(:create_plan)
    allow_any_instance_of(PaypalPlansService).to receive(:create_plan)
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  let(:stripe_invoice_data) {
    JSON.parse(file_fixture('stripe/invoice_created.json').read).with_indifferent_access
  }

  let(:paypal_invoice_data) {
    JSON.parse(file_fixture('paypal/webhook_payment_sale_completed.json').read).with_indifferent_access
  }

  let(:currency)         { create(:currency) }
  let(:user)             { create(:user, currency: currency) }
  let(:invoice)          { build_stubbed(:invoice) }
  let!(:subscription_01) { create(:subscription, user: user, stripe_guid: stripe_invoice_data[:data][:object][:subscription]) }
  let!(:subscription_02) { create(:subscription, user: user, paypal_subscription_guid: paypal_invoice_data['resource']['billing_agreement_id']) }

  it 'has a valid factory' do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    expect(build(:invoice)).to be_valid
  end

  # Constants
  it { expect(Invoice.const_defined?(:STRIPE_LIVE_MODE)).to eq(true) }

  # relationships
  it { should belong_to(:currency) }
  it { should have_many(:invoice_line_items) }
  it { should belong_to(:subscription) }
  it { should belong_to(:user) }
  it { should belong_to(:vat_rate) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:currency_id) }
  it { should validate_presence_of(:total) }
  it { should validate_length_of(:stripe_guid).is_at_most(255) }
  it { should validate_length_of(:stripe_customer_guid).is_at_most(255) }
  it { should validate_length_of(:object_type).is_at_most(255) }
  it { should validate_length_of(:charge_guid).is_at_most(255) }
  it { should validate_length_of(:subscription_guid).is_at_most(255) }
  ## validation of strip_invoice
  before { allow(subject).to receive(:strip_invoice?).and_return(true) }
  it { should validate_presence_of(:subscription_id) }
  it { should validate_presence_of(:number_of_users) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:set_vat_rate).after(:create) }

  # scopes
  it { expect(Invoice).to respond_to(:all_in_order) }
  it { expect(Invoice).to respond_to(:subscriptions) }
  it { expect(Invoice).to respond_to(:orders) }

  # class methods
  it { expect(Invoice).to respond_to(:to_csv) }
  it { expect(Invoice).to respond_to(:build_from_stripe_data) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:status) }
  it { should respond_to(:update_from_stripe) }

  describe 'Concern' do
    it_behaves_like 'invoice_report'
  end

  describe 'Methods' do
    describe '.build_from_stripe_data' do
      it 'save invoice' do
        allow(User).to receive(:find_by).and_return(user)
        allow(Currency).to receive(:find_by).and_return(currency)
        allow(InvoiceLineItem).to receive(:build_from_stripe_data).and_return(true)

        expect(Invoice.build_from_stripe_data(stripe_invoice_data[:data][:object])).to be_a_kind_of(Invoice)
      end

      it 'dont save invoice' do
        allow(User).to receive(:find_by).and_return(user)
        allow(Currency).to receive(:find_by).and_return(currency)

        expect(Rails.logger).to receive(:error)

        expect(Invoice.build_from_stripe_data(stripe_invoice_data[:data][:object])).to be(nil)
      end

      it 'dont save invoice' do
        allow(User).to receive(:find_by).and_return(user)
        allow(Currency).to receive(:find_by).and_return(currency)
        allow_any_instance_of(Invoice).to receive(:save).and_return(false)

        expect(Rails.logger).to receive(:error)

        expect(Invoice.build_from_stripe_data(stripe_invoice_data[:data][:object])).to be_a_kind_of(Invoice)
      end

      it 'dont save invoice' do
        allow(User).to receive(:find_by).and_return(nil)
        allow(Currency).to receive(:find_by).and_return(currency)
        allow_any_instance_of(Subscription).to receive(:currency).and_return(false)

        expect(Rails.logger).to receive(:error)

        expect(Invoice.build_from_stripe_data(stripe_invoice_data[:data][:object])).to be(nil)
      end
    end

    describe '.build_from_paypal_data' do
      it 'save invoice' do
        allow(InvoiceLineItem).to receive(:build_from_paypal_data).and_return(true)

        expect(Invoice.build_from_paypal_data(paypal_invoice_data)).to be_a_kind_of(Invoice)
      end

      it 'dont save invoice' do
        allow_any_instance_of(Subscription).to receive(:user).and_return(false)
        expect(Rails.logger).to receive(:error)

        expect(Invoice.build_from_paypal_data(paypal_invoice_data)).to be_a_kind_of(Invoice)
      end

      it 'dont save invoice' do
        allow_any_instance_of(Invoice).to receive(:save).and_return(false)

        expect(Rails.logger).to receive(:error)

        expect(Invoice.build_from_paypal_data(paypal_invoice_data)).to be_a_kind_of(Invoice)
      end

      it 'dont save invoice' do
        allow_any_instance_of(Invoice).to receive(:save).and_return(false)

        expect(Rails.logger).to receive(:error)

        expect(Invoice.build_from_paypal_data(paypal_invoice_data)).to be_a_kind_of(Invoice)
      end
    end

    describe '#mark_payment_action_required' do
      let(:invoice_2) { create(:invoice) }

      it 'updates the requires_3d_secure field' do
        allow(invoice_2.subscription).to receive(:mark_payment_action_required!)

        expect{ invoice_2.mark_payment_action_required }.to change{
          invoice_2.requires_3d_secure
        }.from(false).to(true)
      end

      it 'calls the mark_payment_action_required! transition on the subscription' do
        expect(invoice_2.subscription).to receive(:mark_payment_action_required!)

        invoice_2.mark_payment_action_required
      end

      describe 'calls #send_3d_secure_email' do
        it 'calls the Mandrill worker with the receipt email' do
          allow(Rails.env).to receive(:test?).and_return(false)
          expect(Message).to receive(:create)

          invoice.send_receipt('')
        end
      end
    end

    describe '#mark_payment_action_successful' do
      let(:invoice_2) { create(:invoice, requires_3d_secure: true) }

      it 'updates the requires_3d_secure field' do
        allow(invoice_2.subscription).to receive(:restart!)

        expect { invoice_2.mark_payment_action_successful }.to change {
          invoice_2.requires_3d_secure
        }.from(true).to(false)
      end

      it 'calls the mark_payment_action_successful! transition on the subscription' do
        expect(invoice_2.subscription).to receive(:restart!)

        invoice_2.mark_payment_action_successful
      end
    end

    describe '#update_from_stripe' do
      let(:invoice) { create(:invoice, stripe_guid: stripe_invoice_data[:data][:object][:id]) }

      it 'updates invoice with stripe data' do
        allow(Stripe::Invoice).to receive(:retrieve).and_return(stripe_invoice_data[:data][:object])

        expect(invoice.update_from_stripe(invoice.stripe_guid)).to be(true)
      end

      it 'doesnt updates invoice with stripe data' do
        allow(Invoice).to receive(:find_by).and_return(false)
        allow(Stripe::Invoice).to receive(:retrieve).and_return(stripe_invoice_data[:data][:object])

        expect(invoice.update_from_stripe(invoice.stripe_guid)).to be(true)
      end

      it 'doesnt updates invoice with stripe data' do
        allow(Stripe::Invoice).to receive(:retrieve).and_return(nil)

        expect(invoice.update_from_stripe(invoice.stripe_guid)).to be(true)
      end
    end

    describe '#destroyable?' do
      it 'return true' do
        expect(invoice).to be_destroyable
      end

      it 'return false' do
        allow_any_instance_of(Invoice).to receive(:invoice_line_items).and_return([1])

        expect(invoice).not_to be_destroyable
      end
    end

    describe '#status' do
      context 'Paid' do
        before do
          allow_any_instance_of(Invoice).to receive(:paid).and_return(true)
          allow_any_instance_of(Invoice).to receive(:payment_closed).and_return(true)
        end

        it { expect(invoice.status).to eq('Paid') }
      end

      context 'Pending Authentication' do
        before do
          allow_any_instance_of(Invoice).to receive(:paid).and_return(false)
          allow_any_instance_of(Invoice).to receive(:payment_closed).and_return(false)
          allow_any_instance_of(Invoice).to receive(:requires_3d_secure).and_return(true)
        end

        it { expect(invoice.status).to eq('Pending Authentication') }
      end

      context 'Past Due' do
        before do
          allow_any_instance_of(Invoice).to receive(:paid).and_return(false)
          allow_any_instance_of(Invoice).to receive(:payment_attempted).and_return(true)
          allow_any_instance_of(Invoice).to receive(:next_payment_attempt_at).and_return('1')
        end

        it { expect(invoice.status).to eq('Past Due') }
      end

      context 'Pending' do
        before do
          allow_any_instance_of(Invoice).to receive(:paid).and_return(false)
          allow_any_instance_of(Invoice).to receive(:payment_closed).and_return(false)
        end

        it { expect(invoice.status).to eq('Pending') }
      end

      context 'Closed' do
        before do
          allow_any_instance_of(Invoice).to receive(:paid).and_return(false)
          allow_any_instance_of(Invoice).to receive(:payment_closed).and_return(true)
          allow_any_instance_of(Invoice).to receive(:payment_attempted).and_return(true)
        end

        it { expect(invoice.status).to eq('Closed') }
      end

      context 'Other' do
        before do
          allow_any_instance_of(Invoice).to receive(:paid).and_return(false)
          allow_any_instance_of(Invoice).to receive(:payment_closed).and_return(true)
        end

        it { expect(invoice.status).to eq('Other') }
      end
    end

    describe '#send_receipt' do
      describe 'for Rails.env.test?' do
        it 'does nothing' do
          expect(invoice.send_receipt('')).to be_nil
        end
      end

      describe 'for other environments' do
        before :each do
          stub_request(:post, "https://api.intercom.io/users").
            to_return(status: 200, body: "", headers: {})
        end

        it 'calls the Mandrill worker with the receipt email' do
          allow(Rails.env).to receive(:test?).and_return(false)
          expect(Message).to receive(:create)

          invoice.send_receipt('')
        end
      end
    end
  end

  describe '.to_csv' do
    before do
      allow_any_instance_of(StripePlanService).to receive(:create_plan).and_return(true)
      allow_any_instance_of(PaypalPlansService).to receive(:create_plan).and_return(true)
      allow_any_instance_of(Invoice).to receive(:hubspot_get_contact).and_return(nil)
    end

    let(:user)         { create(:user) }
    let(:subscription) { create(:subscription, user: user) }
    let!(:invoice)     { create(:invoice, user: user, subscription: subscription) }

    context 'generate csv data' do
      it { expect(Invoice.all.to_csv.split(',')).to include('inv_id',
                                                            'invoice_created',
                                                            'sub_id',
                                                            'sub_created',
                                                            'user_email',
                                                            'user_created',
                                                            'first_visit_date',
                                                            'first_visit_referring_domain',
                                                            'first_visit_landing_page') }
    end
  end
end
