# == Schema Information
#
# Table name: external_banners
#
#  id                 :integer          not null, primary key
#  name               :string
#  sorting_order      :integer
#  active             :boolean          default("false")
#  background_colour  :string
#  text_content       :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_sessions      :boolean          default("false")
#  library            :boolean          default("false")
#  subscription_plans :boolean          default("false")
#  footer_pages       :boolean          default("false")
#  student_sign_ups   :boolean          default("false")
#  home_page_id       :integer
#  content_page_id    :integer
#  exam_body_id       :integer
#  basic_students     :boolean          default("false")
#  paid_students      :boolean          default("false")
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
