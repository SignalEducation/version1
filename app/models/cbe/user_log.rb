# frozen_string_literal: true

class Cbe
  class UserLog < ApplicationRecord
    # relationships
    belongs_to :cbe
    belongs_to :user
    belongs_to :exercise, optional: true

    has_many :answers, class_name: 'Cbe::UserAnswer', foreign_key: 'cbe_user_log_id',
                       inverse_of: :user_log, dependent: :destroy

    has_many :questions, -> { distinct }, through: :answers

    accepts_nested_attributes_for :answers

    # validations
    validates :cbe_id, presence: true

    # enums
    enum status: { started: 0, paused: 1, finished: 3 }

    # callbacks
    after_update :update_exercise_status, if: proc { |u_log| u_log.status == 'finished' }

    private

    def update_exercise_status
      questions_kind = answers.map { |a| a.question.kind }.uniq

      exercise.submit

      return if questions_kind.include?('spreadsheet' || 'open')

      exercise.correct
      exercise.return
    end
  end
end
