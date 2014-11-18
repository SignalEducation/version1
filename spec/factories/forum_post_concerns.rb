# == Schema Information
#
# Table name: forum_post_concerns
#
#  id            :integer          not null, primary key
#  forum_post_id :integer
#  user_id       :integer
#  reason        :string(255)
#  live          :boolean          default(TRUE), not null
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :forum_post_concern do
    forum_post_id 1
    user_id 1
    reason "MyString"
    live false
  end

end
