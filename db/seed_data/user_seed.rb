unless Rails.env.production?
    generic_default_values = {
            password: '123123123', password_confirmation: '123123123',
            country_id: 1,
            preferred_exam_body_id: 1,
            locale: 'en'
    }
    User.where(id: 1).first_or_create!(generic_default_values.merge({
            email: 'individual.student@example.com',
            first_name: 'Individual',
            last_name: 'Student',
            user_group_id: 1
    })); print '.'

    User.where(id: 2).first_or_create!(generic_default_values.merge({
            email: 'tutor@example.com',
            first_name: 'Doctor',
            last_name: 'Tutor',
            user_group_id: 4
    })); print '.'

    User.where(id: 3).first_or_create!(generic_default_values.merge({
            email: 'blogger@example.com',
            first_name: 'Blogger',
            last_name: 'Writer',
            user_group_id: 5
    })); print '.'

    User.where(id: 4).first_or_create!(generic_default_values.merge({
            email: 'forum.manager@example.com',
            first_name: 'Forum',
            last_name: 'Manager',
            user_group_id: 6
    })); print '.'

    User.where(id: 5).first_or_create!(generic_default_values.merge({
            email: 'content.manager@example.com',
            first_name: 'Content',
            last_name: 'Manager',
            user_group_id: 7
    })); print '.'

    User.where(id: 6).first_or_create!(generic_default_values.merge({
            email: 'site.admin@example.com',
            first_name: 'Site',
            last_name: 'Admin',
            email_verified: true,
            user_group_id: 8
    })); print '.'

    User.where(id: (1..6).to_a).update_all(active: true, account_activated_at: Time.now, account_activation_code: nil)
  end