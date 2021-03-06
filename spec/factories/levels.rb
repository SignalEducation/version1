# == Schema Information
#
# Table name: levels
#
#  id                           :bigint           not null, primary key
#  group_id                     :integer
#  name                         :string
#  name_url                     :string
#  active                       :boolean          default("false"), not null
#  highlight_colour             :string           default("#ef475d")
#  sorting_order                :integer
#  icon_label                   :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  onboarding_course_subheading :text
#  onboarding_course_heading    :string
#
FactoryBot.define do
  factory :level do
    sequence(:name)                { |n| "#{Faker::Movies::LordOfTheRings.location} - #{n}" }
    sequence(:name_url)            { |n| "#{Faker::Internet.slug}-#{n}" }
    active                         { false }
    highlight_colour               { 'MyString' }
    sorting_order                  { 1 }
    icon_label                     { 'MyString' }
    onboarding_course_heading      { Faker::Movies::LordOfTheRings.character }
    onboarding_course_subheading   { Faker::Movies::LordOfTheRings.quote }
    group

    trait :active do
      active { true }
    end
  end
end
