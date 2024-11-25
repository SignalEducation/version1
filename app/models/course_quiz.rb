# == Schema Information
#
# Table name: course_quizzes
#
#  id                          :integer          not null, primary key
#  course_step_id              :integer
#  number_of_questions         :integer
#  question_selection_strategy :string(255)
#  created_at                  :datetime
#  updated_at                  :datetime
#  destroyed_at                :datetime
#

class CourseQuiz < ApplicationRecord

  include LearnSignalModelExtras
  include Archivable

  # Constants
  STRATEGIES = %w(random ordered)

  # relationships
  belongs_to :course_step, optional: true
  has_many :quiz_questions

  accepts_nested_attributes_for :quiz_questions,
                                reject_if: lambda {|attributes| quiz_question_fields_blank?(attributes) }

  # validation
  validates :course_step_id, presence: true, on: :update
  validates :number_of_questions, presence: true, on: :update
  validates :question_selection_strategy, inclusion: {in: STRATEGIES}, length: {maximum: 255}

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:course_step_id).where(destroyed_at: nil) }

  # class methods

  # instance methods
  def parent
    course_step
  end

  def children
    quiz_questions
  end

  def duplicate
    new_cme_quiz =
      deep_clone include: [
        :course_step,
        quiz_questions: [
          :quiz_solutions,
          :quiz_contents,
          quiz_answers: :quiz_contents
        ]
      ], validate: false

    new_cme_quiz.
      course_step.update(name: "#{course_step.name} COPY",
                                   name_url: "#{course_step.name_url}_copy",
                                   active: false)
  end

  ## Checks for num. of Questions created is more than the num. to be asked ##

  def enough_questions?
    self.quiz_questions.count >= self.number_of_questions
  end

  #######################################################################

  ## Builds complex nested attributes ##

  def add_an_empty_question
    quiz_questions.build
    quiz_questions.last.course_quiz_id = id
    quiz_questions.last.quiz_solutions.build
    quiz_questions.last.quiz_contents.build(sorting_order: 1)
    quiz_questions.last.sorting_order = children.try(:maximum, :sorting_order).to_i + 1
    (course_step.try(:course_lesson).try(:course).try(:default_number_of_possible_exam_answers) || 4).times do |number|
      quiz_questions.last.quiz_answers.build
      quiz_questions.last.quiz_answers.last.quiz_contents.build(sorting_order: number + 1)
    end
  end

  #######################################################################

  ## Groups all nested QuizQuestions in a random or ordered array ##

  def all_ids_random
    self.quiz_questions.map(&:id).shuffle
  end

  def all_ids_ordered
    self.quiz_questions.all_in_order.map(&:id)
  end


  #######################################################################

  ## Archivable ability ##

  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list += self.quiz_questions.to_a
    the_list
  end

  protected

  ### TODO research this
  ## Nested Attributes lambda check ##
  def self.quiz_question_fields_blank?(the_attributes)
    (the_attributes['id'].to_i > 0 && the_attributes['quiz_contents_attributes'].blank?) ||
      ( the_attributes['course_quiz_id'].to_i > 0 &&
        # the_attributes['solution_to_the_question'].blank? &&
        the_attributes['difficulty_level'].blank? &&
        the_attributes['quiz_contents_attributes']['0']['text_content'].blank? &&
        # Answer A
        the_attributes['quiz_answers_attributes']['0']['quiz_contents_attributes']['0']['text_content'].blank? &&
        the_attributes['quiz_answers_attributes']['0']['degree_of_wrongness'].blank? &&
        # Answer B
        the_attributes['quiz_answers_attributes']['1'].try(:[],'quiz_contents_attributes').try(:[],'0').try(:[],'text_content').blank? &&
        the_attributes['quiz_answers_attributes']['1'].try(:[],'degree_of_wrongness').blank? &&
        # Answer C
        the_attributes['quiz_answers_attributes']['2'].try(:[],'quiz_contents_attributes').try(:[],'0').try(:[],'text_content').blank? &&
        the_attributes['quiz_answers_attributes']['2'].try(:[],'degree_of_wrongness').blank? &&
        # Answer D
        the_attributes['quiz_answers_attributes']['3'].try(:[],'quiz_contents_attributes').try(:[],'0').try(:[],'text_content').blank? &&
        the_attributes['quiz_answers_attributes']['3'].try(:[],'degree_of_wrongness').blank? &&
        # Answer E
        the_attributes['quiz_answers_attributes']['4'].try(:[],'quiz_contents_attributes').try(:[],'0').try(:[],'text_content').blank? &&
        the_attributes['quiz_answers_attributes']['4'].try(:[],'degree_of_wrongness').blank?
      )
  end

end
