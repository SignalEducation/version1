class AddFreeTrialBooleanToStudentUserTypes < ActiveRecord::Migration
  def up
    add_column :student_user_types, :free_trial, :boolean, default: false, index: true

    unless Rails.env.test?
      StudentUserType.new(name: 'Free Trial Students', description: 'Users who are on a valid free trial.', subscription: false, product_order: false, free_trial: true).tap do |user_type|
        user_type.save!
      end
      StudentUserType.new(name: 'Free Trial and Product Students', description: 'Users who are on a valid free trial. And have purchased a valid course product.', subscription: false, product_order: true, free_trial: true).tap do |user_type|
        user_type.save!
      end
    end

    unless Rails.env.test?
      User.find_each do |user|
        if user.user_group_id == 1
          if user.free_trial && user.trial_limit_in_seconds <= ENV['free_trial_limit_in_seconds'].to_i
            user.student_user_type_id = 5
          elsif !user.free_trial && user.subscriptions.any? && user.active_subscription && ('active past_due canceled-pending').include?(user.active_subscription.current_status)
            user.student_user_type_id = 1
          elsif !user.free_trial && user.subscriptions.any? && user.active_subscription && ('active past_due canceled-pending').include?(user.active_subscription.current_status)
            user.student_user_type_id = 3
          end
          user.save!
        end
      end
    end

  end

  def down
    remove_column :student_user_types, :free_trial, :boolean, default: false, index: true
  end

end
