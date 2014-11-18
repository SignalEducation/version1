FactoryGirl.define do
  factory :user_like do
    user_id 1
    likeable_type "MyString"
    likeable_id 1
  end

end
