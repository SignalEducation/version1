# == Schema Information
#
# Table name: corporate_group_grants
#
#  id                 :integer          not null, primary key
#  corporate_group_id :integer
#  exam_level_id      :integer
#  exam_section_id    :integer
#  compulsory         :boolean
#  restricted         :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  subject_course_id  :integer
#

FactoryGirl.define do
  factory :corporate_group_grant do
    corporate_group_id 1
    exam_level_id nil
    exam_section_id nil
    compulsory false
    restricted false
    subject_course_id 1
  end
end
