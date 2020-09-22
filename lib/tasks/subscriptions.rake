# frozen_string_literal: true

namespace :subscriptions do
  desc 'Updating Subscription kind attribute to change plan when appropiate.'
  task update_kind: :environment do
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Updating Subscription kind attribute...'

    total_time = Benchmark.measure do
      @errors = []
      subs = Subscription.not_pending.where(kind: nil)

      subs.each do |sub|
        if sub.changed_from_id
          sub.update_attribute(:kind, 2)
        else
          type = sub.user.subscriptions.for_exam_body(sub.subscription_plan.exam_body_id).where(state: %w[canceled cancelled]).empty? ? 0 : 1
          sub.update_attribute(:kind, type)
        end
        print '*'
      end
    end

    Rails.logger.info '============ Total time execution ============'
    Rails.logger.info total_time.real
    Rails.logger.info '=============================================='
  end
end
