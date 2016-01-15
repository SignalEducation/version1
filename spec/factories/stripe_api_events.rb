# == Schema Information
#
# Table name: stripe_api_events
#
#  id            :integer          not null, primary key
#  guid          :string
#  api_version   :string
#  payload       :text
#  processed     :boolean          default(FALSE), not null
#  processed_at  :datetime
#  error         :boolean          default(FALSE), not null
#  error_message :string
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :stripe_api_event do
    sequence(:guid)           { |n| "abjO5 #{n}" }
    api_version '2015-02-18'
    payload '1' => 'January', '2' => 'February'
    processed false
    error false
  end

end
