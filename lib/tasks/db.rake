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

end
