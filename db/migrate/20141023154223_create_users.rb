class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, index: true
      t.string :first_name
      t.string :last_name
      t.text :address
      t.integer :country_id, index: true
      t.string :crypted_password, limit: 128, default: '', null: false
      t.string :password_salt, limit: 128, default: '', null: false
      t.string :persistence_token, index: true
      t.string :perishable_token, limit: 128
      t.string :single_access_token
      t.integer :login_count, default: 0
      t.integer :failed_login_count, default: 0
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.string :last_login_ip
      t.string :account_activation_code, index: true
      t.datetime :account_activated_at
      t.boolean :active, default: false, null: false
      t.integer :user_group_id, index: true
      t.datetime :password_reset_requested_at
      t.string :password_reset_token, index: true
      t.datetime :password_reset_at
      t.string :stripe_customer_id, index: true
      t.integer :corporate_customer_id, index: true
      t.integer :corporate_customer_user_group_id, index: true
      t.string :operational_email_frequency
      t.string :study_plan_notifications_email_frequency
      t.string :falling_behind_email_alert_frequency
      t.string :marketing_email_frequency
      t.datetime :marketing_email_permission_given_at
      t.string :blog_notification_email_frequency
      t.string :forum_notification_email_frequency

      t.timestamps
    end
  end
end
