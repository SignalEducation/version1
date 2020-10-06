# frozen_string_literal: true

# == Schema Information
#
# Table name: course_practice_questions
#
#  id             :bigint           not null, primary key
#  name           :string
#  content        :text
#  kind           :integer
#  estimated_time :integer
#  course_step_id :bigint
#  destroyed_at   :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class CoursePracticeQuestion < ApplicationRecord
  include LearnSignalModelExtras
  include Archivable

  # enums
  enum kind: { standard: 0, exhibit: 1 }

  # associations
  belongs_to :course_step
  has_many :answers, class_name: 'PracticeQuestion::Answer',
                     foreign_key: :course_practice_question_id,
                     inverse_of: :practice_question,
                     dependent: :destroy

  # validations
  validates :course_step_id, presence: true, on: :update
  validates :content, presence: true

  accepts_nested_attributes_for :answers
end
