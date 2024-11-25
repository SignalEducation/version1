# == Schema Information
#
# Table name: cbe_sections
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  name          :string
#  cbe_id        :bigint
#  score         :float
#  kind          :integer
#  sorting_order :integer
#  content       :text
#  destroyed_at  :datetime
#  active        :boolean          default("true")
#  random        :boolean          default("false")
#
FactoryBot.define do
  factory :cbe_section, class: Cbe::Section do
    name    { Faker::Lorem.word }
    content { Faker::Lorem.sentence }
    kind    { Cbe::Section.kinds.keys.sample }
    score   { Faker::Number.between(from: 1.0, to: 10.0) }
    sequence(:sorting_order)

    trait :with_cbe do
      association :cbe
    end
  end
end
