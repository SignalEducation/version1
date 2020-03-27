# frozen_string_literal: true

namespace :courses do
  desc 'Update quiz_result to old CME Users Log'
  task quiz_result: :environment do
    logs               = CourseStepLog.quizzes.where(quiz_result: nil)
    logs_not_processed = []

    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Updating course module element user logs...'

    total_time = Benchmark.measure do
      logs.find_in_batches(batch_size: 1000) do |logs_group|
        batch_time = Benchmark.measure do
          ActiveRecord::Base.transaction do
            Rails.logger.info "======= #{logs_group.count} LOGS ========="
            logs_group.each do |log|
              status = log.element_completed ? 'passed' : 'failed'
              saved  = log.update_column(:quiz_result, status)
              logs_not_processed << log.id if false
            rescue => e
              Rails.logger.error "update error in log #{log.id}"
              Rails.logger.error e.message
              logs_not_processed << log.id
            end
          end
        end

        Rails.logger.info '============ Batch time execution ==============='
        Rails.logger.info batch_time.real
        Rails.logger.info '================================================='
      end
    end
    Rails.logger.info '============ Total time execution ==============='
    Rails.logger.info total_time.real
    Rails.logger.info '================================================='

    Rails.logger.error "Attention, these logs didn't create invoices: #{logs_not_processed}!!!" if logs_not_processed.present?
  end
end
