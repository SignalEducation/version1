# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_question_questions
#
#  id                          :bigint           not null, primary key
#  kind                        :integer
#  content                     :json
#  solution                    :json
#  sorting_order               :integer
#  course_practice_question_id :bigint
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  description                 :text
#
module PracticeQuestion
  class Question < ApplicationRecord
    self.table_name_prefix = 'practice_question_'

    # enums
    enum kind: { open: 0, spreadsheet: 1 }

    # relationships
    has_many   :answers, inverse_of: :question, class_name: 'PracticeQuestion::Answer',
                         foreign_key: :practice_question_question_id,
                         dependent: :nullify
    belongs_to :practice_question, class_name: 'CoursePracticeQuestion',
                                   foreign_key: :course_practice_question_id,
                                   inverse_of: :questions

    # validations
    validates :course_practice_question_id, presence: true, on: :update
    validates :solution, presence: true

    # callbacks

    before_save :parse_spreadsheet

    def parse_spreadsheet
      return if open?

      self.content  = JSON.parse(content) if content&.present? && content.kind_of?(String)
      self.solution = JSON.parse(solution) if solution&.present? && solution.kind_of?(String)
    end

    def parsed_content
      parser_content(content)
    end

    def parsed_solution
      parser_content(solution)
    end

    protected

    def parser_content(json)
      return if open? || json.blank?

      json.to_json
    end
  end
end
