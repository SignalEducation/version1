# == Schema Information
#
# Table name: exam_sections
#
#  id                                :integer          not null, primary key
#  name                              :string
#  name_url                          :string
#  exam_level_id                     :integer
#  active                            :boolean          default(FALSE), not null
#  sorting_order                     :integer
#  best_possible_first_attempt_score :float
#  created_at                        :datetime
#  updated_at                        :datetime
#  cme_count                         :integer          default(0)
#  seo_description                   :string
#  seo_no_index                      :boolean          default(FALSE)
#  duration                          :integer
#

FactoryGirl.define do
  factory :exam_section do
    sequence(:name)       {|n| "Exam Section #{n}"}
    sequence(:name_url)   {|n| "exam-section-#{n}"}
    exam_level_id         { ExamLevel.first.try(:id) || FactoryGirl.create(:exam_level).id }
    sequence(:sorting_order) {|n| n * 10}
    seo_description       'Lorem ipsum'
    seo_no_index           false

    factory :active_exam_section do
      active              true
    end

    factory :inactive_exam_section do
      active              false
    end
  end

end
