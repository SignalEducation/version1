# frozen_string_literal: true

class Cbe
  class UserAnswer < ApplicationRecord
    # relationships
    belongs_to :user_log, class_name: 'Cbe::UserLog', foreign_key: 'cbe_user_log_id',
                          inverse_of: :answers, optional: true
    belongs_to :question, class_name: 'Cbe::UserQuestion', foreign_key: 'cbe_user_question_id',
                          inverse_of: :answers, optional: true

    # validations
    validates :content, presence: true
  end
end
