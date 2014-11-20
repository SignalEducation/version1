# == Schema Information
#
# Table name: user_exam_levels
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  exam_level_id    :integer
#  exam_schedule_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

FactoryGirl.define do
  factory :user_exam_level do
    user_id 1
    exam_level_id 1
    exam_schedule_id 1
  end

end
