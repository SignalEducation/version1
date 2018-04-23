# == Schema Information
#
# Table name: faq_sections
#
#  id            :integer          not null, primary key
#  name          :string
#  name_url      :string
#  description   :text
#  active        :boolean          default(TRUE)
#  sorting_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :faq_section do
    name "MyString"
    name_url "MyString"
    description "MyText"
    active false
    sorting_order 1
  end
end
