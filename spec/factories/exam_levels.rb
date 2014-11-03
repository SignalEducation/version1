# == Schema Information
#
# Table name: exam_levels
#
#  id                                :integer          not null, primary key
#  qualification_id                  :integer
#  name                              :string(255)
#  name_url                          :string(255)
#  is_cpd                            :boolean          default(FALSE), not null
#  sorting_order                     :integer
#  active                            :boolean          default(FALSE), not null
#  best_possible_first_attempt_score :float
#  created_at                        :datetime
#  updated_at                        :datetime
#

FactoryGirl.define do
  factory :exam_level do
    qualification_id 1
    name 'MyString'
    name_url 'MyString'
    is_cpd false
    sorting_order 1
    active false
    best_possible_first_attempt_score 1.5
  end

end
