# == Schema Information
#
# Table name: subject_courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  live                                    :boolean          default(FALSE), not null
#  wistia_guid                             :string
#  tutor_id                                :integer
#  cme_count                               :integer
#  video_count                             :integer
#  quiz_count                              :integer
#  question_count                          :integer
#  description                             :text
#  short_description                       :string
#  mailchimp_guid                          :string
#  forum_url                               :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  best_possible_first_attempt_score       :float
#  default_number_of_possible_exam_answers :integer
#  restricted                              :boolean          default(FALSE), not null
#  corporate_customer_id                   :integer
#  total_video_duration                    :float            default(0.0)
#  destroyed_at                            :datetime
#  is_cpd                                  :boolean          default(FALSE)
#  cpd_hours                               :float
#  cpd_pass_rate                           :integer
#  live_date                               :datetime
#  certificate                             :boolean          default(FALSE), not null
#

class SubjectCourse < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :name, :name_url, :sorting_order, :active, :live, :wistia_guid, :tutor_id, :cme_count, :description, :short_description, :mailchimp_guid, :forum_url, :default_number_of_possible_exam_answers, :restricted, :corporate_customer_id, :is_cpd,
 :cpd_hours, :cpd_pass_rate, :live_date, :certificate

  # Constants

  # relationships
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  has_and_belongs_to_many :groups
  has_many :course_modules
  has_many :course_module_elements, through: :course_modules
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :course_module_jumbo_quizzes, through: :course_modules
  has_one :question_bank
  has_many :student_exam_tracks
  has_many :subject_course_user_logs
  has_many :corporate_group_grants

  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true,
            length: {maximum: 255}
  validates :wistia_guid, allow_nil: true, length: {maximum: 255}
  validates :tutor_id, presence: true
  validates :description, presence: true
  validates :short_description, allow_nil: true, length: {maximum: 255}
  validates :mailchimp_guid, allow_nil: true, length: {maximum: 255}
  validates :forum_url, allow_nil: true, length: {maximum: 255}
  validates :default_number_of_possible_exam_answers, presence: true

  # callbacks
  before_validation { squish_fields(:name, :name_url) }
  before_save :calculate_best_possible_score, :sanitize_name_url
  before_destroy :check_dependencies
  after_create :update_sitemap
  after_update :update_course_logs

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_live, -> { where(live: true) }
  scope :all_not_live, -> { where(live: false) }
  scope :all_not_restricted, -> { where(restricted: false) }
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :for_corporates, -> { where.not(corporate_customer_id: nil) }
  scope :for_public, -> { where(corporate_customer_id: nil) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first
  end

  def self.search(search)
    if search
      where('name ILIKE ? OR description ILIKE ? OR short_description ILIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      SubjectCourse.all_active.all_in_order
    end
  end

  # instance methods
  def active_children
    self.children.all_active.all_in_order
  end

  def children
    self.course_modules.all
  end

  def completed_by_user_or_guid(user_id, session_guid)
    self.percentage_complete_by_user_or_guid(user_id, session_guid) == 100
  end

  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list += self.course_modules.to_a
    the_list << self.question_bank if self.question_bank
    the_list << self.groups if self.groups
    the_list << self.corporate_group_grants if self.corporate_group_grants
    the_list
  end

  def estimated_time_in_seconds
    self.children.sum(:estimated_time_in_seconds)
  end

  def first_active_cme
    self.active_children.first.try(:first_active_cme)
  end

  def number_complete_by_user_or_guid(user_id, session_guid)
    log = self.subject_course_user_logs.for_user_or_session(user_id, session_guid).first
    log.try(:count_of_cmes_completed)
  end

  def parent
    self.groups.all_in_order.first
  end

  def percentage_complete_by_user_or_guid(user_id, session_guid)
    if cme_count.nil?
      0
    else
      if self.cme_count > 0
        (self.number_complete_by_user_or_guid(user_id, session_guid).to_f / self.cme_count.to_f * 100).to_i
      else
        0
      end

    end
  end

  def project_data
    Wistia::Stats::Project.get("#{self.wistia_guid}")
  end

  def total_project_hours_watched
    data = Wistia::Stats::Project.get("#{self.wistia_guid}")
    data['hours_watched']
  end

  def monthly_project_hours_watched
    raw_data = Wistia::Stats::Project.get("#{self.wistia_guid}/by_date", start_date: "#{Proc.new{Time.now.beginning_of_month }.call}", end_date: "#{Proc.new{Time.now}.call}")
    monthly_project_data = []
    raw_data.each do |data|
      monthly_project_data << data['hours_watched']
    end
    monthly_project_data.inject(:+)
  end

  def last_6_months_project_data
    Wistia::Stats::Project.get("#{self.wistia_guid}/by_date", start_date: "#{Proc.new{Time.now - 6.months}.call}", end_date: "#{Proc.new{Time.now}.call}")
  end

  def total_questions_answered
    cmeuls = CourseModuleElementUserLog.where(is_quiz: true).where(course_module_id: self.children)
    total_questions_answered = []
    cmeuls.each do |log|
      total_questions_answered << log.quiz_attempts.count
    end
    total_questions_answered.inject(:+)
  end

  def monthly_questions_answered
    monthly_cmeuls = CourseModuleElementUserLog.this_month.where(is_quiz: true).where(course_module_id: self.children)
    monthly_questions_answered = []
    monthly_cmeuls.each do |log|
      monthly_questions_answered << log.quiz_attempts.count
    end
    monthly_questions_answered.inject(:+)
  end

  def tutor_name
    self.tutor.full_name
  end

  def recalculate_fields
    recalculate_cme_count
    recalculate_quiz_count
    set_question_count
    recalculate_video_count
    set_total_video_duration
    self.save
  end

  protected

  def calculate_best_possible_score
    self.best_possible_first_attempt_score = self.course_module_element_quizzes.sum(:best_possible_score_first_attempt)
  end

  def recalculate_cme_count
    self.cme_count = self.active_children.sum(:cme_count)
  end

  def recalculate_quiz_count
    self.quiz_count = self.active_children.sum(:quiz_count)
  end

  def recalculate_video_count
    self.video_count = self.active_children.sum(:video_count)
  end

  def set_question_count
    self.question_count = self.active_children.sum(:number_of_questions)
  end

  def set_total_video_duration
    video_duration = self.active_children.sum(:video_duration)
    quiz_duration = self.active_children.sum(:estimated_time_in_seconds)
    self.total_video_duration = video_duration + quiz_duration
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def update_course_logs
    SubjectCourseUserLogWorker.perform_async(self.id)
  end

end
