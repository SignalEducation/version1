# == Schema Information
#
# Table name: external_banners
#
#  id                 :integer          not null, primary key
#  name               :string
#  sorting_order      :integer
#  active             :boolean          default(FALSE)
#  background_colour  :string
#  text_content       :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_sessions      :boolean          default(FALSE)
#  library            :boolean          default(FALSE)
#  subscription_plans :boolean          default(FALSE)
#  footer_pages       :boolean          default(FALSE)
#  student_sign_ups   :boolean          default(FALSE)
#  home_page_id       :integer
#  content_page_id    :integer
#

FactoryBot.define do
  factory :external_banner do
    sequence(:name)                  { |n| "banner-#{n}" }
    sorting_order { 1 }
    active { false }
    background_colour { "MyString" }
    text_content { "MyText" }
  end
end
