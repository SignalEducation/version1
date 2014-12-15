# == Schema Information
#
# Table name: quiz_answers
#
#  id                            :integer          not null, primary key
#  quiz_question_id              :integer
#  correct                       :boolean          default(FALSE), not null
#  degree_of_wrongness           :string(255)
#  wrong_answer_explanation_text :text
#  wrong_answer_video_id         :integer
#  created_at                    :datetime
#  updated_at                    :datetime
#

class QuizAnswer < ActiveRecord::Base

  # attr-accessible
  attr_accessible :quiz_question_id, :degree_of_wrongness, :wrong_answer_explanation_text, :wrong_answer_video_id, :quiz_contents_attributes

  # Constants
  WRONGNESS = ['correct', 'slightly wrong', 'wrong', 'very wrong']

  # relationships
  has_many :quiz_attempts
  has_many :quiz_contents, -> { order(:sorting_order) }, dependent: :destroy
  belongs_to :quiz_question
  belongs_to :wrong_answer_video, class_name: 'CourseModuleElement', foreign_key: :wrong_answer_video_id

  accepts_nested_attributes_for :quiz_contents, allow_destroy: true

  # validation
  validates :quiz_question_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :degree_of_wrongness, inclusion: {in: WRONGNESS}
  validates :wrong_answer_explanation_text, presence: true, unless: "degree_of_wrongness == 'correct'"
  validates :wrong_answer_video_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update

  # callbacks
  before_save :set_the_field_correct
  before_update :set_wrong_answer_video_id
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:quiz_question_id) }

  # class methods

  # instance methods
  def destroyable?
    self.quiz_attempts.empty? && self.quiz_contents.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def set_the_field_correct
    self.correct = self.degree_of_wrongness == 'correct'
    true
  end

  def set_wrong_answer_video_id
    self.wrong_answer_video_id = self.quiz_question.course_module_element.related_video_id
  end

end
