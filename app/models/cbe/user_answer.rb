# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_user_answers
#
#  id                   :bigint           not null, primary key
#  content              :json
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  cbe_answer_id        :bigint
#  cbe_user_question_id :bigint
#
class Cbe
  class UserAnswer < ApplicationRecord
    # relationships
    belongs_to :question, class_name: 'Cbe::UserQuestion', foreign_key: 'cbe_user_question_id',
                          inverse_of: :answers, optional: true

    # validations
    validates :content, presence: true
  end
end
