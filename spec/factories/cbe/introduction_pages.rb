# == Schema Information
#
# Table name: cbe_introduction_pages
#
#  id            :bigint           not null, primary key
#  sorting_order :integer
#  content       :text
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cbe_id        :bigint
#  kind          :integer          default("0"), not null
#
FactoryBot.define do
  factory :cbe_introduction_page, class: Cbe::IntroductionPage do
    content { Faker::Lorem.paragraph(sentence_count: rand(30..99)) }
    title   { Faker::Lorem.sentence }
    sequence(:sorting_order)

    trait :with_cbe do
      association :cbe
    end
  end
end
