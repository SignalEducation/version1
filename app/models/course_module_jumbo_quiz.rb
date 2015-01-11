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
#  name_url                        :string(255)
#

class CourseModuleJumboQuiz < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :course_module_id, :name, :name_url, :minimum_question_count_per_quiz,
                  :maximum_question_count_per_quiz, :total_number_of_questions

  # Constants

  # relationships
  belongs_to :course_module
  has_many :course_module_element_quizzes

  # validation
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :name_url, presence: true
  validates :minimum_question_count_per_quiz, presence: true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :maximum_question_count_per_quiz, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :total_number_of_questions, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_validation { squish_fields(:name) }
  before_save :sanitize_name_url

  # scopes
  scope :all_in_order, -> { order(:course_module_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def name_url
    name_url_sanitizer(self.name)
  end

  protected

end
