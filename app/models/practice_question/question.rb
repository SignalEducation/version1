# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_question_question
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
  class Question < ApplicationRecord
    self.table_name_prefix = 'practice_question_'

    # enums
    enum kind: { open: 0, spreadsheet: 1 }

    # relationships
    belongs_to :practice_question, class_name: 'CoursePracticeQuestion',
                                   foreign_key: :course_practice_question_id,
                                   inverse_of: :questions

    validates :course_practice_question_id, presence: true, on: :update
    validates :content, :solution, presence: true
  end
end
