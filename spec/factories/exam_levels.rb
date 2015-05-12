# == Schema Information
#
# Table name: exam_levels
#
#  id                                      :integer          not null, primary key
#  qualification_id                        :integer
#  name                                    :string(255)
#  name_url                                :string(255)
#  is_cpd                                  :boolean          default(FALSE), not null
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  best_possible_first_attempt_score       :float
#  created_at                              :datetime
#  updated_at                              :datetime
#  default_number_of_possible_exam_answers :integer          default(4)
#  enable_exam_sections                    :boolean          default(TRUE), not null
#  cme_count                               :integer          default(0)
#  seo_description                         :string(255)
#  seo_no_index                            :boolean          default(FALSE)
#  description                             :text
#  duration                                :integer
#

FactoryGirl.define do
  factory :exam_level do
    association :qualification
    sequence(:name)      { |x| "Exam Level #{x}" }
    sequence(:name_url)  { |x| "exam-level-#{x}" }
    is_cpd               false
    sorting_order        1
    active               false
    default_number_of_possible_exam_answers 4
    enable_exam_sections true
    description          'Lorem Ipsum'
    seo_description      'Lorem ipsum'
    seo_no_index         false

    factory :active_exam_level do
      active                       true
      factory :active_exam_level_with_exam_sections do
        enable_exam_sections       true
      end
      factory :active_exam_level_without_exam_sections do
        enable_exam_sections       false
      end
    end

    factory :inactive_exam_level do
      active                       false
    end
    factory :inactive_exam_level_with_exam_sections do
      enable_exam_sections       true
    end
    factory :inactive_exam_level_without_exam_sections do
      enable_exam_sections       false
    end

  end

end
