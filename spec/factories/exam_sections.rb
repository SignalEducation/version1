# == Schema Information
#
# Table name: exam_sections
#
#  id                                :integer          not null, primary key
#  name                              :string(255)
#  name_url                          :string(255)
#  exam_level_id                     :integer
#  active                            :boolean          default(FALSE), not null
#  sorting_order                     :integer
#  best_possible_first_attempt_score :float
#  created_at                        :datetime
#  updated_at                        :datetime
#

FactoryGirl.define do
  factory :exam_section do
    sequence(:name)       {|n| "Exam Level #{n}"}
    sequence(:name_url)   {|n| "exam-level-#{n}"}
    exam_level_id          { ExamLevel.first.try(:id) || 1 }
    sequence(:sorting_order) {|n| n * 10}
    best_possible_first_attempt_score 1.5

    factory :active_institution do
      active              true
    end

    factory :inactive_institution do
      active              false
    end
  end

end
