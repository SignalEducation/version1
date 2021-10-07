# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_question_responses
#
#  id                   :bigint           not null, primary key
#  practice_question_id :integer
#  sorting_order        :integer
#  kind                 :integer
#  content              :json
#  course_step_log_id   :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
module PracticeQuestion
  class Response < ApplicationRecord
    self.table_name_prefix = 'practice_question_'

    # enums
    enum kind: { open: 0, spreadsheet: 1 }

    # relationships
    belongs_to :course_step_log, foreign_key: :course_step_log_id, inverse_of: :practice_question_responses
    belongs_to :practice_question, class_name: 'CoursePracticeQuestion',
                                   foreign_key: :practice_question_id,
                                   inverse_of: :responses, optional: true

    # scopes
    scope :all_in_order, -> { order(:sorting_order, :id) }

    # validations
    validates :practice_question_id, presence: true

    # instance methods

    ## Check if the Currency can be deleted ##
    def destroyable?
      true
    end
  end
end
