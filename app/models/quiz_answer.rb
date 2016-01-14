# == Schema Information
#
# Table name: quiz_answers
#
#  id                            :integer          not null, primary key
#  quiz_question_id              :integer
#  correct                       :boolean          default(FALSE), not null
#  degree_of_wrongness           :string
#  wrong_answer_explanation_text :text
#  wrong_answer_video_id         :integer
#  created_at                    :datetime
#  updated_at                    :datetime
#  destroyed_at                  :datetime
#

class QuizAnswer < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :quiz_question_id, :degree_of_wrongness, :wrong_answer_explanation_text, :wrong_answer_video_id, :quiz_contents_attributes

  # Constants
  #WRONGNESS = ['correct', 'slightly wrong', 'wrong', 'very wrong']
  WRONGNESS = ['correct', 'incorrect']

  # relationships
  has_many :quiz_attempts
  has_many :quiz_contents, -> { order(:sorting_order) }, dependent: :destroy
  belongs_to :quiz_question
  belongs_to :wrong_answer_video, class_name: 'CourseModuleElement', foreign_key: :wrong_answer_video_id

  accepts_nested_attributes_for :quiz_contents, allow_destroy: true

  # validation
  validates :quiz_question_id, presence: true, on: :update
  validates :degree_of_wrongness, inclusion: {in: WRONGNESS}, length: {maximum: 255}

  # callbacks
  before_validation { squish_fields(:wrong_answer_explanation_text) }
  before_save :set_the_field_correct
  #before_update :set_wrong_answer_video_id

  # scopes
  scope :all_in_order, -> { order(:quiz_question_id).where(destroy_at: nil) }
  scope :ids_in_specific_order, lambda { |array_of_ids| where(id: array_of_ids).order("CASE #{array_of_ids.map.with_index{|x,c| "WHEN id= #{x} THEN #{c} " }.join } END") }
  scope :correct, -> { where(correct: true) }

  # class methods
  # def self.ids_in_specific_order(array_of_ids)
  #   where(id: array_of_ids).order("CASE #{array_of_ids.map.with_index{|x,c| "WHEN id= #{x} THEN #{c} " }.join } END")
  # end ##### now I'm a scope!

  # instance methods
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

  #def set_wrong_answer_video_id
    #self.wrong_answer_video_id = self.quiz_question.course_module_element.try(:related_video_id)
  #end

end
