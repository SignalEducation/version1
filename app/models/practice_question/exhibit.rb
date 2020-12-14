# frozen_string_literal: true

# == Schema Information
#
# Table name: practice_question_exhibits
#
#  id                    :bigint           not null, primary key
#  name                  :string
#  practice_question_id  :integer
#  sorting_order         :integer
#  kind                  :integer
#  content               :json
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :bigint
#  document_updated_at   :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
module PracticeQuestion
  class Exhibit < ApplicationRecord
    self.table_name_prefix = 'practice_question_'

    has_attached_file :document

    # enums
    enum kind: { open: 0, spreadsheet: 1, document: 2 }

    # relationships
    belongs_to :practice_question, class_name: 'CoursePracticeQuestion',
                                   foreign_key: :practice_question_id,
                                   inverse_of: :exhibits, optional: true

    # scopes
    scope :all_in_order, -> { order(:sorting_order, :id) }

    # validations
    validates :practice_question_id, presence: true
    validates :name, presence: true
    validates :content, presence: true, if: -> { open? || spreadsheet? }
    validates_attachment_presence :document, unless: -> { open? || spreadsheet? }
    validates_attachment_content_type :document, content_type: %w[application/pdf]

    # instance methods

    ## Check if the Currency can be deleted ##
    def destroyable?
      true
    end
  end
end
