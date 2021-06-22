# frozen_string_literal: true

namespace :total_revenue do
  desc 'Update the total orders and subscriptions revenue.'
  task update: :environment do
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Updating total revenue from users...'

    total_time = Benchmark.measure do
      @errors = []
      batches = User.includes(:subscriptions, :invoices).
                  where(subscriptions: { state: %i[incomplete active past_due canceled canceled-pending pending_cancellation] }).
                  find_in_batches(batch_size: 100)

      batches.each do |users|
        ActiveRecord::Base.transaction do
          Rails.logger.info "======= #{users.count} USERS ========="
          bench_time = Benchmark.measure do
            users.each do |user|
              user.update(orders_revenue: 0, subscriptions_revenue: 0)
              user.subscriptions.update_all(total_revenue: 0)

              user.invoices.each do |invoice|
                Rails.logger.info "======= Update value from invoice ##{invoice.id} from user ##{user.id}. ========="
                invoice.update_total_revenue
              end

              user.refunds.each do |refund|
                Rails.logger.info "======= Update value from refund ##{refund.id} from user ##{user.id}. ========="
                invoice.update_total_revenue
              end
            end
          end
          Rails.logger.info '============ Bench time execution ==============='
          Rails.logger.info bench_time.real
          Rails.logger.info '================================================='
        end
      end
    end

    Rails.logger.info '============ Total time execution ============'
    Rails.logger.info total_time.real
    Rails.logger.info '=============================================='
  end
end
