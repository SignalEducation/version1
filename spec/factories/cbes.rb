FactoryBot.define do
  factory :cbe do
    name { "MyString" }
    title { "MyString" }
    desciption { "MyText" }
    exam_time { 1.5 }
    hard_time_limit { 1.5 }
    number_of_pauses_allowed { 1 }
    exam_body { "" }
    length_of_pauses { 1 }
  end
end
