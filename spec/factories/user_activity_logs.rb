# == Schema Information
#
# Table name: user_activity_logs
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  session_guid    :string(255)
#  signed_in       :boolean          default(FALSE), not null
#  original_uri    :string(255)
#  controller_name :string(255)
#  action_name     :string(255)
#  params          :text
#  alert_level     :integer          default(0)
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :user_activity_log do
    user_id 1
    session_guid 'MyString'
    signed_in false
    original_uri 'MyString'
    controller_name 'MyString'
    action_name 'MyString'
    params { {name: 'abc', some_val: 123} }
    alert_level 0
  end

end
