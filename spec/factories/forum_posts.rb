FactoryGirl.define do
  factory :forum_post do
    user_id 1
content "MyText"
forum_topic_id 1
blocked false
response_to_forum_post_id 1
  end

end
