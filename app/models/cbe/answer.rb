# frozen_string_literal: true

class Cbe
  class Answer < ApplicationRecord
    # enum
    include CbeQuestionTypes

    # relationships
    belongs_to :question, class_name: 'Cbe::Question', foreign_key: 'cbe_question_id',
                          inverse_of: :answers

    # validations
    validates :kind, :cbe_question_id, presence: true
  end
end
