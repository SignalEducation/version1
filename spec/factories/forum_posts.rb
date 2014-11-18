# == Schema Information
#
# Table name: forum_posts
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  content                   :text
#  forum_topic_id            :integer
#  blocked                   :boolean          default(FALSE), not null
#  response_to_forum_post_id :integer
#  created_at                :datetime
#  updated_at                :datetime
#

FactoryGirl.define do
  factory :forum_post do
    user_id 1
    content 'MyText'
    forum_topic_id 1
    blocked false
    response_to_forum_post_id 1
  end

end
