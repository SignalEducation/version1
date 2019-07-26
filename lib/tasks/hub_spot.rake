# frozen_string_literal: true

namespace :hub_spot do
  desc 'Update/Create contacts in HubSpot.'
  task create_contacts: :environment do
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Creating/Updating contacts...'

    total_time = Benchmark.measure do
      @errors  = []
      batches = User.where.not(email: blacklist).find_in_batches(batch_size: 100)

      batches.each do |users|
        User.transaction do
          Rails.logger.info "======= #{users.count} USERS ========="
          bench_time = Benchmark.measure do
            response = HubSpot::Contacts.new.batch_create(users.pluck(:id))
            unless response.code == '202'
              Rails.logger.error 'Error to create contacts'
              Rails.logger.error response.body
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

def blacklist
  file = Rails.root.join('lib', 'assets', 'blacklists', 'email_not_exists.csv')
  CSV.read(file).flatten
end
