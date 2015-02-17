# == Schema Information
#
# Table name: user_activity_logs
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  session_guid              :string(255)
#  signed_in                 :boolean          default(FALSE), not null
#  original_uri              :text
#  controller_name           :string(255)
#  action_name               :string(255)
#  params                    :text
#  alert_level               :integer          default(0)
#  created_at                :datetime
#  updated_at                :datetime
#  ip_address                :string(255)
#  browser                   :string(255)
#  operating_system          :string(255)
#  phone                     :boolean          default(FALSE), not null
#  tablet                    :boolean          default(FALSE), not null
#  computer                  :boolean          default(FALSE), not null
#  guid                      :string(255)
#  ip_address_id             :integer
#  browser_version           :string(255)
#  raw_user_agent            :string(255)
#  session_landing_page      :string(255)
#  post_sign_up_redirect_url :string(255)
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
    sequence(:guid) { |n| "ABC-#{n}" }
    ip_address 'MyString'
  end

end
