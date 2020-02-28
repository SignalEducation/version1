# == Schema Information
#
# Table name: stripe_api_events
#
#  id            :integer          not null, primary key
#  guid          :string(255)
#  api_version   :string(255)
#  payload       :text
#  processed     :boolean          default("false"), not null
#  processed_at  :datetime
#  error         :boolean          default("false"), not null
#  error_message :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryBot.define do
  factory :stripe_api_event do
    sequence(:guid)           { |n| "abjO5 #{n}" }
    api_version { '2015-02-18' }
    payload { { '1' => 'January', '2' => 'February' } }
    processed { false }
    error { false }
  end
end
