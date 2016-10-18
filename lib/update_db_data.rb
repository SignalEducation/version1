class UpdateDBData

  def self.update_comp_user_group
    user_group = UserGroup.find 9
    user_group.update_attributes(complimentary: true, individual_student: false)
  end

  def self.create_student_user_types
    types = StudentUserType.all
    types.each do |type|
      type.destroy
    end

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
  end

  def self.update_student_users
    users = User.where(user_group_id: 1)
    ActiveRecord::Base.transaction do
      users.each do |user|

        if user.free_trial && user.trial_limit_in_seconds <= ENV['free_trial_limit_in_seconds'].to_i
          user.student_user_type_id = StudentUserType.default_free_trial_user_type.id
        elsif !user.free_trial && user.subscriptions.any? && user.active_subscription && ('active past_due canceled-pending').include?(user.active_subscription.current_status)
          user.student_user_type_id = StudentUserType.default_sub_user_type.id
        elsif !user.free_trial && user.subscriptions.any? && user.active_subscription && !('active past_due canceled-pending').include?(user.active_subscription.current_status)
          user.student_user_type_id = StudentUserType.default_no_access_user_type.id
        else
          user.student_user_type_id = StudentUserType.default_no_access_user_type.id
        end
        user.save!
      end
    end

  end


end