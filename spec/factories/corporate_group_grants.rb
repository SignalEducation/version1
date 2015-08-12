FactoryGirl.define do
  factory :corporate_group_grant do
    corporate_group_id 1
    exam_level_id 1
    exam_section_id nil
    compulsory false
    restricted false
  end
end
