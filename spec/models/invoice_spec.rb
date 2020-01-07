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
#  stripe_guid                 :string
#  sub_total                   :decimal(, )      default(0.0)
#  total                       :decimal(, )      default(0.0)
#  total_tax                   :decimal(, )      default(0.0)
#  stripe_customer_guid        :string
#  object_type                 :string           default("invoice")
#  payment_attempted           :boolean          default(FALSE)
#  payment_closed              :boolean          default(FALSE)
#  forgiven                    :boolean          default(FALSE)
#  paid                        :boolean          default(FALSE)
#  livemode                    :boolean          default(FALSE)
#  attempt_count               :integer          default(0)
#  amount_due                  :decimal(, )      default(0.0)
#  next_payment_attempt_at     :datetime
#  webhooks_delivered_at       :datetime
#  charge_guid                 :string
#  subscription_guid           :string
#  tax_percent                 :decimal(, )
#  tax                         :decimal(, )
#  original_stripe_data        :text
#  paypal_payment_guid         :string
#  order_id                    :bigint(8)
#

require 'rails_helper'

describe Invoice do
  it 'has a valid factory' do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    expect(create(:invoice)).to be_valid
  end

  # Constants
  it { expect(Invoice.const_defined?(:STRIPE_LIVE_MODE)).to eq(true) }

  # relationships
  it { should belong_to(:currency) }
  it { should have_many(:invoice_line_items) }
  it { should belong_to(:subscription_transaction).optional }
  it { should belong_to(:subscription).optional }
  it { should belong_to(:user) }
  it { should belong_to(:vat_rate).optional }

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
  it { expect(Invoice).to respond_to(:build_from_stripe_data) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:status) }
  it { should respond_to(:update_from_stripe) }

  describe 'instance methods' do
    let(:invoice) { build_stubbed(:invoice) }

    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
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
          expect(MandrillWorker).to receive(:perform_async)

          invoice.send_receipt('')
        end
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
          expect(MandrillWorker).to receive(:perform_async)

          invoice.send_receipt('')
        end
      end
    end
  end
end
