# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
unless Rails.env.test? # don't want this stuff to run in the test DB  
  print "* " * 100
  load "db/seed_data/exam_body.rb"
  load "db/seed_data/group.rb"
  load "db/seed_data/user_group.rb"
  load "db/seed_data/currency_seed.rb"
  load "db/seed_data/countries_seed.rb"
  puts " \n >> exam_body group user_group currency countries"
        #load "db/seed_data/user_countries.rb"
  print "* " * 100
  load "db/seed_data/subject_course.rb"
  load "db/seed_data/user_seed.rb"
  load "db/seed_data/subscription_plan_seed.rb"

  puts "\n subject_course user subscription_plan"

  print "* " * 100
  load "db/seed_data/course_seed.rb"
  load "db/seed_data/course_content_data.rb"
  puts "\n course course_content_data"
        
  print "* " * 100
  puts "\n Completed the db/seed process"
  puts '*' * 100

end
