# == Schema Information
#
# Table name: paypal_webhooks
#
#  id           :integer          not null, primary key
#  guid         :string
#  event_type   :string
#  payload      :text
#  processed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  verified     :boolean          default("true")
#

require 'rails_helper'

describe PaypalWebhook do
  # validation
  it { should validate_presence_of(:guid) }
  it { should validate_presence_of(:payload) }
  it { should validate_presence_of(:event_type) }

  it 'has a valid factory' do
    expect(build(:paypal_webhook)).to be_valid
  end

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:process_sale_completed) }
  it { should respond_to(:process_sale_denied) }
  it { should respond_to(:process_subscription_cancelled) }
  it { should respond_to(:reprocess) }

  describe 'instance methods' do
    let(:paypal_webhook) { create(:paypal_webhook) }
    let(:subscription) { build_stubbed(:subscription) }

    describe '#verify_subscription' do
      it 'sets #verified to TRUE if a subscription exists' do
        allow(Subscription).to receive(:find_by).and_return(subscription)
        expect(paypal_webhook).to receive(:update!).with(verified: true)

        paypal_webhook.verify_subscription('test')
      end
      it 'sets #verified to FALSE if a subscription does not exist' do
        allow(Subscription).to receive(:find_by).and_return(nil)

        expect { paypal_webhook.verify_subscription('test') }.to change { paypal_webhook.verified }.from(true).to(false)
      end
    end

    describe 'process_subscription_cancelled' do
      it 'calls #verify_subscription' do
        expect(paypal_webhook).to receive(:verify_subscription)

        paypal_webhook.process_subscription_cancelled
      end
    end

    describe 'process_subscription_suspended' do
      it 'calls #verify_subscription' do
        expect(paypal_webhook).to receive(:verify_subscription)

        paypal_webhook.process_subscription_suspended
      end
    end
  end
end
