# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_user_logs
#
#  id               :bigint           not null, primary key
#  status           :integer
#  score            :float
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  cbe_id           :bigint
#  user_id          :bigint
#  exercise_id      :bigint
#  educator_comment :text
#  agreed           :boolean          default("false")
#  current_state    :string
#  scratch_pad      :text
#  pages_state      :json
#
class Cbe
  class UserLog < ApplicationRecord
    # relationships
    belongs_to :cbe
    belongs_to :user
    belongs_to :exercise, optional: true, inverse_of: :cbe_user_log, dependent: :destroy

    has_many :questions, class_name: 'Cbe::UserQuestion', foreign_key: 'cbe_user_log_id',
                         inverse_of: :user_log, dependent: :destroy
    has_many :responses, class_name: 'Cbe::UserResponse', foreign_key: 'cbe_user_log_id',
                         inverse_of: :user_log, dependent: :destroy

    accepts_nested_attributes_for :questions
    accepts_nested_attributes_for :responses

    # validations
    validates :cbe_id, presence: true

    # enums
    enum status: { started: 0, paused: 1, finished: 3, corrected: 4 }

    # callbacks
    before_save   :default_status
    before_update :update_score
    after_update  :update_exercise_status, if: proc { |u_log| u_log.status == 'finished' }

    def update_score
      self.score = exhibits? ? responses.map(&:score).sum : questions.map(&:score).sum
    end

    def default_status
      self.status ||= 'started'
    end

    def sections_in_user_log
      questions.includes(:section).map(&:section).uniq.sort_by(&:sorting_order)
    end

    def scenarios_in_user_log
      cbe.scenarios.select(&:active)
    end

    def exhibits?
      responses.present?
    end

    private

    def update_exercise_status
      questions_kind = questions.map { |q| q.cbe_question.kind }.uniq

      exercise&.submit

      return if responses.present?
      return unless questions_kind.exclude?('open') &&
                    questions_kind.exclude?('spreadsheet')

      exercise&.correct
      exercise&.return
    end
  end
end
