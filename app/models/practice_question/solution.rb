# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_question_solutions
#
#  id                    :bigint           not null, primary key
#  name                  :string
#  practice_question_id  :integer
#  sorting_order         :integer
#  kind                  :integer
#  content               :json
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
module PracticeQuestion
  class Solution < ApplicationRecord
    self.table_name_prefix = 'practice_question_'

    # enums
    enum kind: { open: 0, spreadsheet: 1 }

    # relationships
    belongs_to :practice_question, class_name: 'CoursePracticeQuestion',
                                    foreign_key: :practice_question_id,
                                    inverse_of: :solutions, optional: true

    # scopes
    scope :all_in_order, -> { order(:sorting_order, :id) }

    # validations
    validates :practice_question_id, presence: true
    validates :name, presence: true
    validates :content, presence: true, if: -> { open? || spreadsheet? }

    # instance methods

    ## Check if the Currency can be deleted ##
    def destroyable?
      true
    end
  end
end
