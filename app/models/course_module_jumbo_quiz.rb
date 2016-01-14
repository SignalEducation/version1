# == Schema Information
#
# Table name: course_module_jumbo_quizzes
#
#  id                                :integer          not null, primary key
#  course_module_id                  :integer
#  name                              :string
#  minimum_question_count_per_quiz   :integer
#  maximum_question_count_per_quiz   :integer
#  total_number_of_questions         :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  name_url                          :string
#  best_possible_score_first_attempt :integer          default(0)
#  best_possible_score_retry         :integer          default(0)
#  destroyed_at                      :datetime
#  active                            :boolean          default(FALSE), not null
#

class CourseModuleJumboQuiz < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :course_module_id, :name, :name_url,
                  :minimum_question_count_per_quiz,
                  :maximum_question_count_per_quiz,
                  :total_number_of_questions,
                  :active

  # Constants

  # relationships
  belongs_to :course_module
  has_many :course_module_element_quizzes
  has_many :course_module_element_user_logs

  # validation
  validates :course_module_id, presence: true
  validates :name, presence: true, length: {maximum: 255}
  validates :name_url, presence: true, length: { maximum: 255 }
  validates :minimum_question_count_per_quiz, presence: true
  validates :maximum_question_count_per_quiz, presence: true
  validates :total_number_of_questions, presence: true

  # callbacks
  before_validation { squish_fields(:name) }
  before_save :sanitize_name_url
  before_save :calculate_best_possible_scores
  after_create :update_student_exam_tracks
  after_update :update_course_module

  # scopes
  scope :all_in_order, -> { order(:course_module_id).where(destroyed_at: nil) }
  scope :all_active, -> { where(active: true, destroyed_at: nil) }

  # class methods

  # instance methods
  def completed_by_user_or_guid(user_id, session_guid)
    user_id ?
            self.course_module_element_user_logs.where(user_id: user_id).count > 0 :
            self.course_module_element_user_logs.where(user_id: nil, session_guid: session_guid).count > 0
  end

  def destroyable?
    !Rails.env.production?
  end

  def destroyable_children
    the_list = []
    the_list += self.course_module_element_quizzes.to_a
    the_list
  end

  def name_url
    name_url_sanitizer(self.name)
  end

  def parent
    self.course_module
  end

  def type_name
    "Jumbo Quiz"
  end

  protected

  def calculate_best_possible_scores
    self.best_possible_score_retry = self.total_number_of_questions *
            ApplicationController::DIFFICULTY_LEVELS[-1][:score]
    self.best_possible_score_first_attempt = self.best_possible_score_retry -
            (ApplicationController::DIFFICULTY_LEVELS[-1][:score] *
            ApplicationController::DIFFICULTY_LEVELS.length)
    ApplicationController::DIFFICULTY_LEVELS.length.times do |counter|
      self.best_possible_score_first_attempt += ApplicationController::DIFFICULTY_LEVELS[counter][:score]
    end
  end

  def update_student_exam_tracks
    #StudentExamTracksWorker.perform_async(self.course_module_id)
    #true
    StudentExamTrack.where(course_module_id: self.course_module_id).each do |set|
      set.recalculate_completeness
    end

  end

  def update_course_module
    self.parent.try(:save)
  end
end
