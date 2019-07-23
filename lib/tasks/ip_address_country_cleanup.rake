# frozen_string_literal: true

desc 'Cleaning up the badly geocoded IP Addresses'
task ip_address_cleanup: :environment do
  Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
  Rails.logger.info 'Running command to clean up ip_address records...'

  total_time = Benchmark.measure do
    IpAddress.where(rechecked_on: nil).find_in_batches(batch_size: 1000) do |ip_addresses|
      IpAddress.transaction do
        Rails.logger.info "======= #{ip_addresses.count} IP ADDRESSES ========="
        bench_time = Benchmark.measure do
          ip_addresses.each do |ip|
            if ip.update(latitude: nil, longitude: nil)
              run_ip_update(ip)
            else
              Rails.logger.error "#{ip.id} was not updated"
            end
          end
        end
        Rails.logger.info "=========== Bench time #{bench_time.real} =========="
      end
    end
  end
  Rails.logger.info "============= Total time #{total_time.real} =============="
  Rails.logger.info '=========================================================='
end

def run_ip_update(ip)
  ip.reverse_geocode
  if ip.latitude.nil?
    Rails.logger.error("Geocoder error for IP Address #{ip.id}")
  else
    ip.update(rechecked_on: Time.zone.now)
  end
end
