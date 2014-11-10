# == Schema Information
#
# Table name: course_module_jumbo_quizzes
#
#  id                              :integer          not null, primary key
#  course_module_id                :integer
#  name                            :string(255)
#  minimum_question_count_per_quiz :integer
#  maximum_question_count_per_quiz :integer
#  total_number_of_questions       :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#

class CourseModuleJumboQuiz < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_id, :name, :minimum_question_count_per_quiz,
                  :maximum_question_count_per_quiz, :total_number_of_questions

  # Constants

  # relationships
  belongs_to :course_module

  # validation
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :minimum_question_count_per_quiz, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :maximum_question_count_per_quiz, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :total_number_of_questions, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
