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
#  destroyed_at          :datetime
#  image_file_name       :string
#  image_content_type    :string
#  image_file_size       :integer
#  image_updated_at      :datetime
#  background_colour     :string
#

FactoryGirl.define do
  factory :group do
    sequence(:name)           { |n| "Group #{n}" }
    sequence(:name_url)           { |n| "group-#{n}" }
    active true
    sorting_order 1
    description 'MyText'
    subject_id nil
  end

end
