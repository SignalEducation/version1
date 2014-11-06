namespace :db do

  desc 'Reset the test environment database'
  task :reset_test do
    # USAGE: rake db:reset_test
    puts 'Reinitializing the test database...'
    system('RAILS_ENV=test rake db:drop db:create db:migrate')
    puts 'DONE'
  end

  desc 'Quick migration into TEST and DEV databases'
  task :quick_migrate do
    # USAGE: rake db:quick_migrate
    puts 'Quick migration to TEST and DEV...'
    system('RAILS_ENV=test rake db:migrate && RAILS_ENV=development rake db:migrate && annotate')
    puts 'DONE'
  end

end
