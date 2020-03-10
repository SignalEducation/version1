# frozen_string_literal: true

# == Schema Information
#
# Table name: quiz_answers
#
#  id                  :integer          not null, primary key
#  quiz_question_id    :integer
#  correct             :boolean          default("false"), not null
#  degree_of_wrongness :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  destroyed_at        :datetime
#

class QuizAnswer < ApplicationRecord
  include LearnSignalModelExtras
  include Archivable

  # Constants
  WRONGNESS = %w[correct incorrect].freeze

  # relationships
  has_many :quiz_attempts, dependent: :destroy
  has_many :quiz_contents, -> { order(:sorting_order) }, inverse_of: :quiz_answer, dependent: :destroy
  belongs_to :quiz_question

  accepts_nested_attributes_for :quiz_contents, allow_destroy: true

  # validation
  validates :quiz_question_id, presence: true, on: :update
  validates :degree_of_wrongness, inclusion: { in: WRONGNESS }, length: { maximum: 255 }

  # callbacks
  before_save :set_the_field_correct

  # scopes
  scope :correct, -> { where(correct: true) }
  scope :all_in_order, -> { order(:quiz_question_id).where(destroy_at: nil) }
  scope :ids_in_specific_order, lambda { |array_of_ids|
    where(id: array_of_ids).order("CASE #{array_of_ids.map.with_index { |x, c| "WHEN id = #{x} THEN #{c} " }.join} END")
  }

  ## Archivable methods ##
  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list += quiz_contents.to_a
    the_list
  end

  protected

  def set_the_field_correct
    self.correct = degree_of_wrongness == 'correct'
    true
  end
end
