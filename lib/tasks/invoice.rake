Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))

namespace :invoices do
  desc 'sorting out the dodgy paypal webhook payloads'
  task :fix_not_updated_invoices => :environment do
    Rails.logger.info 'Updating Invoices...'
    puts 'Running command to clean up webhook records...'

    total_time = Benchmark.measure do
      batches = Invoice.joins(:order).where(paid: false, orders: { state: 'completed' }).
                  find_in_batches(batch_size: 100)

      batches.each do |invoices|
        ActiveRecord::Base.transaction do
          Rails.logger.info "======= #{invoices.count} INVOICES ========="
          bench_time = Benchmark.measure do
            invoices.each do |invoice|
              Rails.logger.info "Invoice ##{invoice.id} updated."
              invoice.update(paid: true, payment_closed: true)
            rescue ActiveRecord::ActiveRecordError => e
              Rails.logger.error "Error to update invoice ##{invoice.id}"
              Rails.logger.error "Error #{e.message}"
            end
          end

          Rails.logger.info '============ batch time execution ==============='
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
