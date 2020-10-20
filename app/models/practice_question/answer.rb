# frozen_string_literal: true

module PracticeQuestion
  class Answer < ApplicationRecord
    self.table_name_prefix = 'practice_question_'

    # relationships
    belongs_to :practice_question_questions, class_name: 'PracticeQuestion::Question',
                                              foreign_key: :practice_question_question_id,
                                              inverse_of: :answers

    validates :practice_question_question_id, presence: true, on: :update
    validates :content, presence: true
  end
end
