class CreateStudentUserTypes < ActiveRecord::Migration
  def up
    create_table :student_user_types do |t|
      t.string :name, index: true
      t.text :description
      t.boolean :subscription, default: false, index: true
      t.boolean :product_order, default: false, index: true

      t.timestamps null: false
    end

    unless Rails.env.test?
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

  end

  def down
    drop_table :student_user_types
  end

end
