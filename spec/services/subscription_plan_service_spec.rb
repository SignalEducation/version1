require 'rails_helper'

describe SubscriptionPlanService, type: :service do
  let(:plan) { build_stubbed(:subscription_plan) }
  let(:sub_plan_service) { SubscriptionPlanService.new(plan) }

  # INSTANCE METHODS ###########################################################

  describe '#queue_async' do
    it 'queues up the background worker' do
      expect(SubscriptionPlanWorker).to receive(:perform_async).with(plan.id, :create)

      sub_plan_service.queue_async(:create)
    end
  end

  describe '#async_action' do
    it 'calls #create_remote_plans when :create is passed in' do
      expect(sub_plan_service).to receive(:create_remote_plans)

      sub_plan_service.async_action(:create)
    end

    it 'calls #update_remote_plans when :update is passed in' do
      expect(sub_plan_service).to receive(:update_remote_plans)

      sub_plan_service.async_action(:update)
    end

    it 'can handle a string being passed in as a string' do
      expect(sub_plan_service).to receive(:create_remote_plans)

      sub_plan_service.async_action('create')
    end
  end

  # PRIVATE METHODS ############################################################

  describe '#create_remote_plans' do
    before :each do
      allow_any_instance_of(StripePlanService).to receive(:create_plan)
      allow_any_instance_of(PaypalPlansService).to receive(:create_plan)
    end

    it 'calls #create_plan on an instance of StripePlanService' do
      expect_any_instance_of(StripePlanService).to receive(:create_plan)

      sub_plan_service.send(:create_remote_plans)
    end

    it 'calls #create_plan on an instance of PaypalPlansService' do
      expect_any_instance_of(PaypalPlansService).to receive(:create_plan)

      sub_plan_service.send(:create_remote_plans)
    end
  end

  describe '#update_remote_plans' do
    before :each do
      allow_any_instance_of(StripePlanService).to receive(:update_plan)
      allow_any_instance_of(PaypalPlansService).to receive(:update_plan)
    end

    it 'calls #update_plan on an instance of StripePlanService' do
      expect_any_instance_of(StripePlanService).to receive(:update_plan)

      sub_plan_service.send(:update_remote_plans)
    end

    it 'calls #update_plan on an instance of PaypalPlansService' do
      expect_any_instance_of(PaypalPlansService).to receive(:update_plan)

      sub_plan_service.send(:update_remote_plans)
    end
  end
end