# == Schema Information
#
# Table name: external_banners
#
#  id                :integer          not null, primary key
#  name              :string
#  sorting_order     :integer
#  active            :boolean          default(FALSE)
#  background_colour :string
#  text_content      :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryBot.define do
  factory :external_banner do
    name "MyString"
    sorting_order 1
    active false
    background_colour "MyString"
    text_content "MyText"
  end
end
