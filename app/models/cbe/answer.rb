# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_answers
#
#  id              :bigint           not null, primary key
#  kind            :integer
#  content         :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cbe_question_id :bigint
#
class Cbe
  class Answer < ApplicationRecord
    # enum
    include CbeQuestionTypes

    # relationships
    belongs_to :question, class_name: 'Cbe::Question', foreign_key: 'cbe_question_id',
                          inverse_of: :answers

    # validations
    validates :kind, presence: true
  end
end
