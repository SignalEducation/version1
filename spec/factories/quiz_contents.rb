# == Schema Information
#
# Table name: quiz_contents
#
#  id               :integer          not null, primary key
#  quiz_question_id :integer
#  quiz_answer_id   :integer
#  text_content     :text
#  contains_mathjax :boolean          not null
#  contains_image   :boolean          not null
#  sorting_order    :integer
#  created_at       :datetime
#  updated_at       :datetime
#

FactoryGirl.define do
  factory :quiz_content do
    quiz_question_id 1
    quiz_answer_id 1
    text_content "MyText"
    contains_mathjax false
    contains_image false
    sorting_order 1
  end

end
