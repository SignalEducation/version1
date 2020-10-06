# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_questions_answers
#
#  id                          :bigint           not null, primary key
#  kind                        :integer
#  content                     :json
#  solution                    :json
#  sorting_order               :integer
#  course_practice_question_id :bigint
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
module PracticeQuestion
  class Answer < ApplicationRecord
    self.table_name_prefix = 'practice_questions_'

    # enums
    enum kind: { open: 0, spreadsheet: 1 }

    # relationships
    belongs_to :practice_question, class_name: 'CoursePracticeQuestion',
                                   foreign_key: :course_practice_question_id,
                                   inverse_of: :answers
  end
end
