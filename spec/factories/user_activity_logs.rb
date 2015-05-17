# == Schema Information
#
# Table name: user_activity_logs
#
#  id                               :integer          not null, primary key
#  user_id                          :integer
#  session_guid                     :string
#  signed_in                        :boolean          default(FALSE), not null
#  original_uri                     :text
#  controller_name                  :string
#  action_name                      :string
#  params                           :text
#  alert_level                      :integer          default(0)
#  created_at                       :datetime
#  updated_at                       :datetime
#  ip_address                       :string
#  browser                          :string
#  operating_system                 :string
#  phone                            :boolean          default(FALSE), not null
#  tablet                           :boolean          default(FALSE), not null
#  computer                         :boolean          default(FALSE), not null
#  guid                             :string
#  ip_address_id                    :integer
#  browser_version                  :string
#  raw_user_agent                   :string
#  first_session_landing_page       :text
#  latest_session_landing_page      :text
#  post_sign_up_redirect_url        :string
#  marketing_token_id               :integer
#  marketing_token_cookie_issued_at :datetime
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
