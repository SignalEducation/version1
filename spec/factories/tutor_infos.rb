# == Schema Information
#
# Table name: tutor_infos
#
#  id                :integer          not null, primary key
#  course_id :string
#  sorting_order     :integer
#  name              :string
#  title             :string
#  description       :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryBot.define do
  factory :tutor_info do
    user_id { "MyString" }
    sorting_order { 1 }
    title { "MyString" }
    description { "MyText" }
    name_url { "MyString" }
  end
end
