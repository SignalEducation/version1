# == Schema Information
#
# Table name: forum_topic_users
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  forum_topic_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :forum_topic_user do
    user_id 1
    forum_topic_id 1
  end

end
