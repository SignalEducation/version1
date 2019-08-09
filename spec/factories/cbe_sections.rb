FactoryBot.define do
  factory :cbe_section do
    name { "MyString" }
    references { "" }
    scenario_description { "MyText" }
    question_description { "MyText" }
    scenario_label { "MyString" }
    question_label { "MyString" }
  end
end
