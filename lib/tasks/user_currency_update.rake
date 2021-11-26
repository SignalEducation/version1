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

  desc 'Update currency of users from a mixpanel test file.'
  task update_currency_from_mixepanel_test: :environment do
    ActiveRecord::Base.logger = nil
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Updating users...'

    total_time = Benchmark.measure do
      # email, country mp, country hs
      mixpanel_data = users_mixpanel_test

      User.transaction do
        mixpanel_data.each do |data|
          email            = data.first
          country_mixpanel = data.second
          country_hubspot  = data.third

          user = User.find_by(email: email)

          Rails.logger.info "======= User - #{email}  ========="
          Rails.logger.info "======= Country Mix Panel #{country_mixpanel}  ========="
          Rails.logger.info "======= Country HubSpot #{country_hubspot}  ============"
          Rails.logger.info "======= Country Database #{user.country.name}  ========="

          currency_from_order           = get_currency_from_orders_subs(user)
          country_data_from_mixpanel    = Country.find_by(name: country_mixpanel)

          if currency_from_order.nil?
            Rails.logger.info "=================== PROCESSING ========================="
            Rails.logger.info "======= Updating user currency from #{user.country.currency.iso_code} to #{country_data_from_mixpanel.currency.iso_code}  ========="
            Rails.logger.info "======= Updating user country from #{user.country.iso_code} to #{country_data_from_mixpanel.iso_code}  ========="
            unless user.update_attributes(country: country_data_from_mixpanel, currency: country_data_from_mixpanel.currency)
              Rails.logger.error "#{user.id} was not updated"
              Rails.logger.error user.errors.messages
            end
          else
            Rails.logger.info "================= NOT PROCESSING ========================"
            Rails.logger.info "======= User ordered using currency #{currency_from_order.iso_code}, csv data ->  #{country_mixpanel}.  ========="
          end
          Rails.logger.info "========================================================"
          Rails.logger.info "========================================================"
        end
      end
    end

    Rails.logger.info '============ Total time execution ============'
    Rails.logger.info total_time.real
    Rails.logger.info '=============================================='
  end

  desc 'Update currency of users from a mixpanel file.'
  task update_currency_from_mixepanel: :environment do
    ActiveRecord::Base.logger = nil
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Updating users...'

    total_time = Benchmark.measure do
      # email, country mp, country hs
      mixpanel_data = users_mixpanel

      mixpanel_data.each do |data|
        email            = data.first
        country_mixpanel = data.second
        country_hubspot  = data.third

        user = User.find_by(email: email)
        if user.nil?
          Rails.logger.info "=================== ERROR ========================="
          Rails.logger.info "=================== User #{email} not found. ========================="
          next
        end


        Rails.logger.info "======= User - #{email}  ========="
        Rails.logger.info "======= Country Mix Panel #{country_mixpanel}  ========="
        Rails.logger.info "======= Country HubSpot #{country_hubspot}  ============"
        Rails.logger.info "======= Country Database #{user.country.name}  ========="

        currency_from_order           = get_currency_from_orders_subs(user)
        country_data_from_mixpanel    = Country.find_by(name: country_mixpanel)

        if country_data_from_mixpanel.nil?
          Rails.logger.info "=================== ERROR ========================="
          Rails.logger.info "=================== User #{country_mixpanel} not found. ========================="
          next
        end

        if currency_from_order.nil?
          Rails.logger.info "=================== PROCESSING ========================="
          Rails.logger.info "======= Updating user currency from #{user.country.currency.iso_code} to #{country_data_from_mixpanel.currency.iso_code}  ========="
          Rails.logger.info "======= Updating user country from #{user.country.iso_code} to #{country_data_from_mixpanel.iso_code}  ========="
          unless user.update_attributes(country: country_data_from_mixpanel, currency: country_data_from_mixpanel.currency)
            Rails.logger.error "#{user.id} was not updated"
            Rails.logger.error user.errors.messages
          end
        else
          Rails.logger.info "================= NOT PROCESSING ========================"
          Rails.logger.info "======= User ordered using currency #{currency_from_order.iso_code}, csv data ->  #{country_mixpanel}.  ========="
        end
        Rails.logger.info "========================================================"
        Rails.logger.info "========================================================"
      end
    end

    Rails.logger.info '============ Total time execution ============'
    Rails.logger.info total_time.real
    Rails.logger.info '=============================================='
  end

  desc 'Update currency of users from a mixpanel_todays file.'
  task update_currency_from_mixepanel_todays: :environment do
    ActiveRecord::Base.logger = nil
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Updating users...'

    total_time = Benchmark.measure do
      # email, country mp
      mixpanel_data = users_mixpanel_todays

      User.transaction do
        mixpanel_data.each do |data|
          email            = data.first
          country_mixpanel = data.second

          user = User.find_by(email: email)

          if user.nil?
            Rails.logger.info "=================== ERROR ========================="
            Rails.logger.info "=================== User #{email} not found. ========================="
            next
          end

          Rails.logger.info "======= User - #{email}  ========="
          Rails.logger.info "======= Country Mix Panel #{country_mixpanel}  ========="
          Rails.logger.info "======= Country Database #{user.country.name}  ========="

          currency_from_order           = get_currency_from_orders_subs(user)
          country_data_from_mixpanel    = Country.find_by(name: country_mixpanel)

          if currency_from_order.nil?
            Rails.logger.info "=================== PROCESSING ========================="
            Rails.logger.info "======= Updating user currency from #{user.country.currency.iso_code} to #{country_data_from_mixpanel.currency.iso_code}  ========="
            Rails.logger.info "======= Updating user country from #{user.country.iso_code} to #{country_data_from_mixpanel.iso_code}  ========="
            unless user.update_attributes(country: country_data_from_mixpanel, currency: country_data_from_mixpanel.currency)
              Rails.logger.error "#{user.id} was not updated"
              Rails.logger.error user.errors.messages
            end
          else
            Rails.logger.info "================= NOT PROCESSING ========================"
            Rails.logger.info "======= User ordered using currency #{currency_from_order.iso_code}, csv data ->  #{country_mixpanel}.  ========="
          end
          Rails.logger.info "========================================================"
          Rails.logger.info "========================================================"
        end
      end
    end

    Rails.logger.info '============ Total time execution ============'
    Rails.logger.info total_time.real
    Rails.logger.info '=============================================='
  end

  desc 'Update hubspot from users mixpanel files.'
  task update_hubspot_from_mixepanel_files: :environment do
    ActiveRecord::Base.logger = nil
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Updating users...'
    return if Rails.env.test?

    total_time = Benchmark.measure do
      # email, country mp
      mixpanel_data        = users_mixpanel.map(&:first)
      mixpanel_data_todays = users_mixpanel_todays
        time_limit = 10

        mixpanel_data.each do |data|
          email = data.first
          user  = User.find_by(email: email)

          if user.present?
            Rails.logger.info "=================== Trigger HubSpotContactWorker========================="
            Rails.logger.info "=================== User #{email} in #{time_limit} seconds. ========================="
            HubSpotContactWorker.perform_at(time_limit.seconds,user.id)
          else
             Rails.logger.info "=================== Error in Trigger HubSpotContactWorker========================="
            Rails.logger.info "=================== User #{email} not found. ========================="
          end
          time_limit = time_limit + 10
        end

        mixpanel_data_todays.each do |data|
          email = data.first
          user  = User.find_by(email: email)

          if user.present?
            Rails.logger.info "=================== Trigger HubSpotContactWorker========================="
            Rails.logger.info "=================== User #{email} in #{time_limit} seconds. ========================="
            HubSpotContactWorker.perform_at(time_limit.seconds,user.id)
          else
             Rails.logger.info "=================== Error in Trigger HubSpotContactWorker========================="
            Rails.logger.info "=================== User #{email} not found. ========================="
          end
time_limit = time_limit + 10
        end
    end

    Rails.logger.info '============ Total time execution ============'
    Rails.logger.info total_time.real
    Rails.logger.info '=============================================='
  end
end

def get_currency_from_orders_subs(user)
  if existing_sub = user.subscriptions.all_stripe.first
    existing_sub.subscription_plan&.currency || user.country.currency
  elsif existing_order = user.orders.all_stripe.first
    existing_order.product&.currency || user.country.currency
  end
end

def users_mixpanel
  file = Rails.root.join('lib/assets/users/mixpanel_final.csv')
  CSV.read(file)
end

def users_mixpanel_todays
  file = Rails.root.join('lib/assets/users/mixpanel_todays.csv')
  CSV.read(file)
end

def users_mixpanel_test
  file = Rails.root.join('lib/assets/users/mixpanel.csv')
  CSV.read(file)
end
