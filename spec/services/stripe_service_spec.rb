require 'rails_helper'

describe StripeService, type: :service do

  # INSTANCE METHODS ###########################################################

  # CUSTOMERS ==================================================================

  describe '#create_customer' do
    let(:user) { create(:user) }

    it 'creates the customer on Stripe' do
      expect(Stripe::Customer).to receive(:create).and_return(double(id: 'stripe_test_id'))

      subject.create_customer(user)
    end

    it 'updates the user with the Stripe customer id' do
      allow(Stripe::Customer).to receive(:create).and_return(double(id: 'stripe_test_id'))

      expect {
        subject.create_customer(user)
      }.to change { user.stripe_customer_id }.from(nil).to('stripe_test_id')
    end
  end

  describe '#get_customer' do
    it 'calls #retrieve on Stripe::Customer with the passed in Stripe ID' do
      expect(Stripe::Customer).to receive(:retrieve).with('stripe_test_id')

      subject.get_customer('stripe_test_id')
    end
  end

  # PLANS ======================================================================

  describe '#create_plan' do
    let(:plan) { build_stubbed(:subscription_plan) }

    it 'calls CREATE on Stripe::Plan with the correct args' do
      expect(Stripe::Plan).to receive(:create)
      allow(subject).to receive(:update_subscription_plan)

      subject.create_plan(plan)
    end

    it 'calls #update_subscription_plan with the correct args' do
      allow(Stripe::Plan).to receive(:create)
      expect(subject).to receive(:update_subscription_plan)

      subject.create_plan(plan)
    end
  end


  # PRIVATE METHODS ############################################################
end