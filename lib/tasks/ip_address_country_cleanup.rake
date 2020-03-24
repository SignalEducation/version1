# frozen_string_literal: true

namespace :ip_address do
  desc 'Cleaning up the badly geocoded IP Addresses'
  task cleanup: :environment do
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Running command to clean up bad ip_address records...'

    total_time = Benchmark.measure do
      records = IpAddress.where('created_at < ?', Time.zone.parse('2019-08-01')).
                  or(IpAddress.where('created_at > ?', Time.zone.parse('2020-02-29'))).
                  where(country_id: [78, 105])
      Rails.logger.info "============= Total Records #{records.count} =============="
      records.in_batches(of: 1000).destroy_all
    end
    Rails.logger.info "============= Total time #{total_time.real} =============="
    Rails.logger.info '=========================================================='
  end

  desc 'Assign the correct countries to users'
  task assign_countries: :environment do
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Running command to assign the correct countries to user records...'

    total_time = Benchmark.measure do
      User.first(100) do |user_records|
        User.transaction do
          Rails.logger.info "======= #{user_records.count} USERS ========="
          bench_time = Benchmark.measure do
            user_records.each do |user|
              visit = user.ahoy_visits.order(started_at: :desc).first
              next if visit.country == user.country.iso_code

              country_id = country_hash[visit.country] || Country.find_by(iso_code: visit.country)&.id
              Rails.logger.error "USER #{user.id} was not updated" unless user.update(country_id: country_id)
            end
          end
          Rails.logger.info "=========== Bench time #{bench_time.real} =========="
        end
      end
    end
    Rails.logger.info "============= Total time #{total_time.real} =============="
    Rails.logger.info '=========================================================='
  end
end

def country_hash
  { 'IE' => 105, 'GB' => 78 }
end
