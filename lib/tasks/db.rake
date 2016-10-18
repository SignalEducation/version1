namespace :db do

  desc 'Reset the test environment database'
  task :reset_test do
    # USAGE: rake db:reset_test
    puts 'Reinitializing the test database...'
    system('RAILS_ENV=test rake db:drop && RAILS_ENV=test rake db:create && RAILS_ENV=test rake db:migrate')
    puts 'DONE'
  end

  desc 'Reset the development environment database'
  task :reset_development do
    # USAGE: rake db:reset_development
    puts 'Reinitializing the development database...'
    system('RAILS_ENV=development rake db:drop && RAILS_ENV=development rake db:create && RAILS_ENV=development rake db:migrate && RAILS_ENV=development rake db:seed && annotate')
    puts 'DONE'
  end

  desc 'Quick migration into TEST and DEV databases'
  task :quick_migrate do
    # USAGE: rake db:quick_migrate
    puts 'Quick migration to TEST and DEV...'
    system('RAILS_ENV=test rake db:migrate && RAILS_ENV=development rake db:migrate && annotate')
    puts 'DONE'
  end

  desc 'Quick roll back out of TEST and DEV databases'
  task :quick_rollback do
    # USAGE: rake db:quick_rollback
    puts 'Quick rollback out of TEST and DEV...'
    system('RAILS_ENV=test rake db:rollback && RAILS_ENV=development rake db:rollback')
    puts 'DONE'
  end

  desc 'Quick roll back and migration for TEST and DEV databases'
  task :quick_reload do
    # USAGE: rake db:quick_reload
    puts 'Quick rollback and re-migration for TEST and DEV...'
    system('RAILS_ENV=test rake db:rollback && RAILS_ENV=development rake db:rollback && RAILS_ENV=test rake db:migrate && RAILS_ENV=development rake db:migrate && annotate')
    puts 'DONE'
  end




  desc 'Update Student User to have a StudentUserTypeID set and Create StudentUserTypes'
  task :update_users do
    # USAGE: rake db:update_users

    puts 'Create Comp and NoAccess UserGroups ...'
    user_group = UserGroup.find 9
    user_group.update_attributes(complimentary: true, individual_student: false)



    puts 'Create StudentUserTypes...'
    StudentUserType.new(name: 'Free Trial Students', description: 'Users who are on a valid free trial.', subscription: false, product_order: false, free_trial: true).tap do |user_type|
      user_type.save!
    end
    StudentUserType.new(name: 'Free Trial and Product Students', description: 'Users who are on a valid free trial. And have purchased a valid course product.', subscription: false, product_order: true, free_trial: true).tap do |user_type|
      user_type.save!
    end
    StudentUserType.new(name: 'Subscription Students', description: 'User with a valid subscription.', subscription: true, product_order: false).tap do |user_type|
      user_type.save!
    end
    StudentUserType.new(name: 'Product Students', description: 'Users who have purchased a course with a one off payment', subscription: false, product_order: true).tap do |user_type|
      user_type.save!
    end
    StudentUserType.new(name: 'No Access Students', description: 'Users who have an expired free trial or created an account but didnt finish the purchase process.', subscription: false, product_order: false).tap do |user_type|
      user_type.save!
    end
    StudentUserType.new(name: 'Subscription and Product Students', description: 'Users who have both a valid subscription and have purchased at least one valid product course.', subscription: true, product_order: true).tap do |user_type|
      user_type.save!
    end

    puts 'Update StudentUsers to have a StudentUserTypeID set...'
    users = User.where(user_group_id: 1)
    ActiveRecord::Base.transaction do
      users.each do |user|

        if user.free_trial && user.trial_limit_in_seconds <= ENV['free_trial_limit_in_seconds'].to_i
          user.student_user_type_id = 5
        elsif !user.free_trial && user.subscriptions.any? && user.active_subscription && ('active past_due canceled-pending').include?(user.active_subscription.current_status)
          user.student_user_type_id = 1
        elsif !user.free_trial && user.subscriptions.any? && user.active_subscription && ('active past_due canceled-pending').include?(user.active_subscription.current_status)
          user.student_user_type_id = 3
        else
          user.student_user_type_id = 3
        end

        user.save!
        print "."
      end
    end

    puts 'DONE'
  end

end
