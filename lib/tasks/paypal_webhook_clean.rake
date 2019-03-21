namespace :paypal do
  desc 'sorting out the dodgy paypal webhook payloads'
  task :webhook_clean => :environment do
    puts 'Running command to clean up webhook records...'
    PaypalWebhook.find_each do |wh|
      puts '================'
      puts wh.id.to_s
      puts 'all okay'
    rescue ActiveRecord::SerializationTypeMismatch => e
      puts "error with Webhook #{wh.id}"
      wh.update_columns(payload: {})
      wh.reprocess
    end
  end
end
