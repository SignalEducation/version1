require 'rails_helper'

describe StripePlanService, type: :service do

  describe '#create_plan' do
    let(:plan) { build_stubbed(:subscription_plan) }
    let(:saved_plan) { create(:subscription_plan) }
    let(:stripe_plan) { double(livemode: true) }

    before :each do
      allow(stripe_plan).to receive(:id).and_return('plan_ff43br4535j4h53j')
      allow(stripe_plan).to receive(:[]).with(:livemode).and_return(true)
      allow(plan).to receive(:update).and_return(true)
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    end

    it 'calls #create_stripe_plan with the correct args' do
      expect(subject).to receive(:create_stripe_plan).and_return(stripe_plan)

      subject.create_plan(plan)
    end

    it 'calls CREATE on Stripe::Plan with the correct args' do
      expect(Stripe::Plan).to receive(:create).and_return(stripe_plan)

      subject.create_plan(plan)
    end

    it 'updates the stripe_guid of a subscription' do
      expect(saved_plan.stripe_guid).to be_nil
      allow(Stripe::Plan).to receive(:create).and_return(stripe_plan)

      subject.create_plan(saved_plan)

      expect(saved_plan.stripe_guid).to eq 'plan_ff43br4535j4h53j'
    end
  end

  describe '#get_plan' do
    it 'calls #retrieve on Stripe::Plan with the correct args' do
      expect(Stripe::Plan).to receive(:retrieve).with(
        { id: 'test_id', expand: ['product'] }
      )

      subject.send(:get_plan, 'test_id')
    end
  end

  describe '#update_plan' do
    let(:plan) { build_stubbed(:subscription_plan, stripe_guid: 'test_id') }

    before :each do
      @dbl = double
      allow(subject).to receive(:get_plan).with('test_id').and_return(@dbl)
      allow(@dbl).to receive_message_chain('product.name=')
      allow(@dbl).to receive_message_chain('product.save')
    end

    it 'calls #get_plan with the correct args' do
      expect(subject).to(
        receive(:get_plan).with('test_id').and_return(@dbl)
      )

      subject.update_plan(plan)
    end

    it 'calls #name= on the Plan with the correct args' do
      expect(@dbl).to receive_message_chain('product.name=').with("LearnSignal #{plan.name}")

      subject.update_plan(plan)
    end

    it 'calls #save on the Plan' do
      expect(@dbl).to receive_message_chain('product.save')

      subject.update_plan(plan)
    end
  end

  describe '#delete_plan' do
    let(:plan) { build_stubbed(:subscription_plan) }

    it 'calls #get_plan with the correct args' do
      dbl = double
      expect(subject).to receive(:get_plan).with('test_id').and_return(dbl)
      allow(dbl).to receive(:delete)

      subject.delete_plan('test_id')
    end

    it 'calls #delete on a Stripe plan if it exists' do
      dbl = double
      allow(subject).to receive(:get_plan).with('test_id').and_return(dbl)
      expect(dbl).to receive(:delete)

      subject.delete_plan('test_id')
    end

    it 'does not call #delete on a Stripe plan if it does not exist' do
      dbl = double
      allow(subject).to receive(:get_plan).with('test_id').and_return(nil)
      expect(dbl).not_to receive(:delete)

      subject.delete_plan('test_id')
    end
  end

  describe '#stripe_plan_id' do
    it 'should return a properly formatted id' do
      expect(subject.send(:stripe_plan_id)).to match 'test-'
    end
  end
end