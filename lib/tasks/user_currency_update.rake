# frozen_string_literal: true

namespace :users do
  desc 'Update currency of users.'

  task update_currency: :environment do
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Updating users...'

    total_time = Benchmark.measure do
      User.where(currency_id: nil).find_in_batches(batch_size: 1000) do |users|
        User.transaction do
          Rails.logger.info "======= #{users.count} USERS ========="
          bench_time = Benchmark.measure do
            users.each do |user|
              currency = get_currency(user)
              next if currency.nil?

              unless user.update_attribute(:currency, currency)
                Rails.logger.error "#{user.id} was not updated"
                Rails.logger.error user.errors.messages
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

def get_currency(user)
  if existing_sub = user.subscriptions.all_stripe.first
    existing_sub.subscription_plan&.currency || user.country.currency
  elsif existing_order = user.orders.all_stripe.first
    existing_order.product&.currency || user.country.currency
  elsif user.country&.currency
    user.country.currency
  else
    Currency.find_by(iso_code: 'GBP')
  end
end
