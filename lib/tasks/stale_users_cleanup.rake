# frozen_string_literal: true

desc 'Cleaning up spam or old users'
task user_cleanup: :environment do
  Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
  Rails.logger.info 'Running command to clean up spam and old user records...'

  total_time = Benchmark.measure do
    User.where(user_group_id: 1,
               created_at: Time.now.in_time_zone.beginning_of_year..Time.now.in_time_zone.beginning_of_day,
               last_request_at: nil, email_verified: false,
               current_login_at: nil, login_count: 0).find_in_batches(batch_size: 50) do |users|
      User.transaction do
        Rails.logger.info "======= #{users.count} User Records ========="
        bench_time = Benchmark.measure do
          users.each do |user|
            if user.destroyable?
              run_user_destroy(user)
            else
              Rails.logger.error "User #{user.id} was not deleted"
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

def run_user_destroy(user)
  Rails.logger.error("User #{user.id} successfully deleted.") if user.destroy
end
