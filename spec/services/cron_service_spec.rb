require 'rails_helper'

describe CronService, type: :service do
  describe '#initiate_task' do
    it 'raises an error unless a valid task is called' do
      expect { subject.initiate_task('test') }.to raise_error(StandardError)
    end

    it 'calls the instance method of the task passed in' do
      expect(subject).to receive(:paypal_sync)

      subject.initiate_task('paypal_sync')
    end
  end

  describe '#paypal_sync' do
    it 'calls #run_paypal_sync on the Paypal::SubscriptionValidation class' do
      expect(PaypalCronWorker).to receive(:perform_async)

      subject.initiate_task('paypal_sync')
    end
  end

  describe '#slack_exercises' do
    it 'calls .send_daily_orders_update on the Order class' do
      expect(Order).to receive(:send_daily_orders_update)

      subject.initiate_task('slack_exercises')
    end
  end

  describe '#daily_sales_report' do
    it 'calls .perform_async on the SalesReportWorker' do
      expect(SalesReportWorker).to receive(:perform_async)

      subject.initiate_task('daily_sales_report')
    end
  end

  describe '#monthly_sales_report' do
    it 'calls .perform_async on the SalesReportWorker' do
      expect(SalesReportWorker).to receive(:perform_async)

      subject.initiate_task('monthly_sales_report')
    end
  end

  describe '#monthly_refunds_report' do
    it 'calls .perform_async on the RefundsReportWorker' do
      expect(RefundsReportWorker).to receive(:perform_async)

      subject.initiate_task('monthly_refunds_report')
    end
  end

  describe '#monthly_orders_report' do
    it 'calls .perform_async on the OrdersReportWorker' do
      expect(OrdersReportWorker).to receive(:perform_async)

      subject.initiate_task('monthly_orders_report')
    end
  end
end
