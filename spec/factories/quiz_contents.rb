# == Schema Information
#
# Table name: quiz_contents
#
#  id                 :integer          not null, primary key
#  quiz_question_id   :integer
#  quiz_answer_id     :integer
#  text_content       :text
#  sorting_order      :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  quiz_solution_id   :integer
#  destroyed_at       :datetime
#

FactoryGirl.define do
  factory :quiz_content do
    text_content 'MyText'
    sorting_order 1

    factory :quiz_content_for_question do
      quiz_question_id 1
      quiz_answer_id nil
      quiz_solution_id nil
    end

    factory :quiz_content_for_answer do
      quiz_question_id nil
      quiz_answer_id 1
      quiz_solution_id nil
    end

    factory :quiz_content_for_solution do
      quiz_question_id nil
      quiz_answer_id nil
      quiz_solution_id 1
    end
  end

end
