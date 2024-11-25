FactoryBot.define do
  factory :cbe_user_log, class: Cbe::UserLog do
    score { Faker::Number.between(from: 1.0, to: 10.0) }
    user  { build(:user) }

    trait :started do
      status { :started }
    end

    trait :paused do
      status { :paused }
    end

    trait :finished do
      status { :finished }
    end

    trait :with_questions do
      questions { build_list :cbe_user_question, 5 }
    end

    trait :with_cbe do
      cbe { build(:cbe) }
    end
  end
end
