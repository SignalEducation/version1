# == Schema Information
#
# Table name: video_resources
#
#  id             :integer          not null, primary key
#  course_step_id :integer
#  question       :text
#  answer         :text
#  notes          :text
#  destroyed_at   :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  transcript     :text
#

FactoryBot.define do
  factory :video_resource do
    question { "MyText" }
    answer { "MyText" }
    notes { "MyText" }
  end

end
