# == Schema Information
#
# Table name: quiz_answers
#
#  id                  :integer          not null, primary key
#  quiz_question_id    :integer
#  correct             :boolean          default(FALSE), not null
#  degree_of_wrongness :string
#  created_at          :datetime
#  updated_at          :datetime
#  destroyed_at        :datetime
#

class QuizAnswer < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :quiz_question_id, :degree_of_wrongness, :quiz_contents_attributes

  # Constants
  WRONGNESS = %w(correct incorrect)

  # relationships
  has_many :quiz_attempts
  has_many :quiz_contents, -> { order(:sorting_order) }, dependent: :destroy
  belongs_to :quiz_question

  accepts_nested_attributes_for :quiz_contents, allow_destroy: true

  # validation
  validates :quiz_question_id, presence: true, on: :update
  validates :degree_of_wrongness, inclusion: {in: WRONGNESS}, length: {maximum: 255}

  # callbacks
  before_save :set_the_field_correct

  # scopes
  scope :all_in_order, -> { order(:quiz_question_id).where(destroy_at: nil) }
  scope :ids_in_specific_order, lambda { |array_of_ids| where(id: array_of_ids).order("CASE #{array_of_ids.map.with_index{|x,c| "WHEN id= #{x} THEN #{c} " }.join } END") }
  scope :correct, -> { where(correct: true) }

  # class methods

  # instance methods

  ## Archivable methods ##
  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list += self.quiz_contents.to_a
    the_list
  end

  protected

  def set_the_field_correct
    self.correct = self.degree_of_wrongness == 'correct'
    true
  end

end
