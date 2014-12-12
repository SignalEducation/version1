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
#

FactoryGirl.define do
  factory :exam_level do
    qualification_id 1
    name 'MyString'
    name_url 'MyString'
    is_cpd false
    sorting_order 1
    active false
    default_number_of_possible_exam_answers 4
  end

end
