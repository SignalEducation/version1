# == Schema Information
#
# Table name: groups
#
#  id                    :integer          not null, primary key
#  name                  :string
#  name_url              :string
#  active                :boolean          default(FALSE), not null
#  sorting_order         :integer
#  description           :text
#  subject_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  corporate_customer_id :integer
#

FactoryGirl.define do
  factory :group do
    sequence(:name)           { |n| "Group #{n}" }
    sequence(:name_url)           { |n| "group-#{n}" }
    active false
    sorting_order 1
    description 'MyText'
    subject_id nil
  end

end
