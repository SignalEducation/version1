require 'rails_helper'

describe CronService, type: :service do
  describe '#initiate_task' do
    it 'raises an error unless a valid task is called' do
      expect { subject.initiate_task('test') }.to raise_error(StandardError)
    end

    it 'calls the instance method of the task passed in' do
      expect(subject).to receive(:ping)

      subject.initiate_task('ping')
    end
  end

  describe '#paypal_sync' do
    it 'calls #run_paypal_sync on the Paypal::SubscriptionValidation class' do
      expect(Paypal::SubscriptionValidation).to receive(:run_paypal_sync)

      subject.initiate_task('paypal_sync')
    end
  end
end