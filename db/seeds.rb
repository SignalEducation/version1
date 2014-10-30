# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
unless Rails.env.test? # don't want this stuff to run in the test DB

  puts '*' * 100
  puts 'Starting the db/seed process'
  puts
  print 'User Groups: '

  UserGroup.where(id: 1).first_or_create!(
          name: 'Individual students', description: 'Self-funded students',
          individual_student: true, tutor: false, content_manager: false,
          blogger: false, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up: true,
          subscription_required_to_see_content: true, forum_manager: false
  ); print '.'

  UserGroup.where(id: 2).first_or_create!(
          name: 'Corporate Student',
          description: 'Student, funded by a corporate customer',
          individual_student: false, corporate_student: true,
          tutor: false, content_manager: false,
          blogger: false, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up: false,
          subscription_required_to_see_content: false, forum_manager: false
  ); print '.'

  UserGroup.where(id: 3).first_or_create!(
          name: 'Corporate customers',
          description: 'Administrative users on behalf of a corporate customer',
          individual_student: false, tutor: false, content_manager: false,
          blogger: false, corporate_customer: true, site_admin: false,
          subscription_required_at_sign_up: true,
          subscription_required_to_see_content: false, forum_manager: false
  ); print '.'

  UserGroup.where(id: 4).first_or_create!(
          name: 'Tutor', description: 'Can create course content',
          individual_student: true, tutor: false, content_manager: false,
          blogger: false, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up:true,
          subscription_required_to_see_content: true, forum_manager: true
  ); print '.'

  UserGroup.where(id: 5).first_or_create!(
          name: 'Blogger', description: 'Can create blog content',
          individual_student: false, tutor: false, content_manager: false,
          blogger: true, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up:false,
          subscription_required_to_see_content: false, forum_manager: false
  ); print '.'

  UserGroup.where(id: 6).first_or_create!(
          name: 'Forum manager', description: 'Can manage content on the forum',
          individual_student: false, tutor: false, content_manager: false,
          blogger: false, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up: false,
          subscription_required_to_see_content: false, forum_manager: true
  ); print '.'

  UserGroup.where(id: 7).first_or_create!(
          name: 'Content manager',
          description: 'Can manage forum, blog and static pages',
          individual_student: false, tutor: false,
          content_manager: true,
          blogger: true, corporate_customer: false, site_admin: false,
          subscription_required_at_sign_up: false,
          subscription_required_to_see_content: false, forum_manager: true
  ); print '.'

  UserGroup.where(id: 8).first_or_create!(
          name: 'Admin', description: 'Can do everything', individual_student: false,
          tutor: false, content_manager: true,
          blogger: true, corporate_customer: false, site_admin: true,
          subscription_required_at_sign_up: false,
          subscription_required_to_see_content: false, forum_manager: true
  ); print '.'

  puts ' DONE'
  print 'Users: '

  unless Rails.env.production?
    generic_default_values = {
            password: '123123123', password_confirmation: '123123123',
            country_id: 1,
            operational_email_frequency: 'daily',
            study_plan_notifications_email_frequency: 'daily',
            falling_behind_email_alert_frequency: 'daily',
            marketing_email_frequency: 'daily',
            blog_notification_email_frequency: 'daily',
            forum_notification_email_frequency: 'daily'
    }
    User.where(id: 1).first_or_create!(generic_default_values.merge({
            email: 'individual.student@example.com',
            first_name: 'Individual',
            last_name: 'Student',
            user_group_id: 1
    })); print '.'

    User.where(id: 2).first_or_create!(generic_default_values.merge({
            email: 'corporate.student@example.com',
            first_name: 'Corporate',
            last_name: 'Student',
            user_group_id: 2, corporate_customer_id: 1
    })); print '.'

    User.where(id: 3).first_or_create!(generic_default_values.merge({
            email: 'corporate.customer@example.com',
            first_name: 'Corporate',
            last_name: 'CustomerUser',
            user_group_id: 3, corporate_customer_id: 1
    })); print '.'

    User.where(id: 4).first_or_create!(generic_default_values.merge({
            email: 'tutor@example.com',
            first_name: 'Doctor',
            last_name: 'Tutor',
            user_group_id: 4
    })); print '.'

    User.where(id: 5).first_or_create!(generic_default_values.merge({
            email: 'blogger@example.com',
            first_name: 'Blogger',
            last_name: 'Writer',
            user_group_id: 5
    })); print '.'

    User.where(id: 6).first_or_create!(generic_default_values.merge({
            email: 'forum.manager@example.com',
            first_name: 'Forum',
            last_name: 'Manager',
            user_group_id: 6
    })); print '.'

    User.where(id: 7).first_or_create!(generic_default_values.merge({
            email: 'content.manager@example.com',
            first_name: 'Content',
            last_name: 'Manager',
            user_group_id: 7
    })); print '.'

    User.where(id: 8).first_or_create!(generic_default_values.merge({
            email: 'site.admin@example.com',
            first_name: 'Site',
            last_name: 'Admin',
            user_group_id: 8
    })); print '.'

    puts ' DONE'
    User.where(id: (1..8).to_a).update_all(active: true, account_activated_at: Time.now, account_activation_code: nil)
  end

  puts
  puts 'Completed the db/seed process'
  puts '*' * 100

end
