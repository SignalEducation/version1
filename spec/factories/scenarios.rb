# == Schema Information
#
# Table name: scenarios
#
#  id                      :integer          not null, primary key
#  constructed_response_id :integer
#  sorting_order           :integer
#  text_content            :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  destroyed_at            :datetime
#

FactoryBot.define do
  factory :scenario do
    constructed_response_id { 1 }
    sorting_order { 1 }
    text_content { 'MyText' }
  end
end
