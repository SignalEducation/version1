# == Schema Information
#
# Table name: user_likes
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  likeable_type :string(255)
#  likeable_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :user_like do
    user_id       1
    likeable_type 'ForumPost'
    likeable_id   { ForumPost.first.try(:id) || 1 }
  end

end
