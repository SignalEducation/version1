# == Schema Information
#
# Table name: exam_levels
#
#  id                                      :integer          not null, primary key
#  qualification_id                        :integer
#  name                                    :string
#  name_url                                :string
#  is_cpd                                  :boolean          default(FALSE), not null
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  best_possible_first_attempt_score       :float
#  created_at                              :datetime
#  updated_at                              :datetime
#  default_number_of_possible_exam_answers :integer          default(4)
#  enable_exam_sections                    :boolean          default(TRUE), not null
#  cme_count                               :integer          default(0)
#  seo_description                         :string
#  seo_no_index                            :boolean          default(FALSE)
#  description                             :text
#  duration                                :integer
#  tutor_id                                :integer
#  live                                    :boolean          default(FALSE), not null
#  short_description                       :text
#

class ExamLevel < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :qualification_id, :name, :name_url, :is_cpd,
                  :sorting_order, :active,
                  :default_number_of_possible_exam_answers,
                  :enable_exam_sections, :description,
                  :seo_description, :seo_no_index, :duration,
                  :tutor_id, :live, :short_description

  # Constants

  # relationships
  has_many :exam_sections
  has_many :course_modules
  has_many :course_module_elements, through: :course_modules
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :course_module_jumbo_quizzes, through: :course_modules
  belongs_to :qualification
  has_many :question_banks
  has_many :student_exam_tracks
  has_many :user_exam_level
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id

  # validation
  validates :qualification_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true,
            uniqueness: {scope: :qualification_id}, length: {maximum: 255}
  validates :name_url, presence: true,
            uniqueness: {scope: :qualification_id}, length: {maximum: 255}
  validates :sorting_order, presence: true
  validates :default_number_of_possible_exam_answers, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :description, presence: true
  validates :seo_description, presence: true, length: {maximum: 255}
  validates :tutor_id, allow_nil: true, numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_validation { squish_fields(:name, :name_url) }
  before_create :set_sorting_order
  before_save :calculate_best_possible_score
  before_save :sanitize_name_url
  before_save :recalculate_cme_count
  before_save :recalculate_duration

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_live, -> { where(live: true) }
  scope :all_not_live, -> { where(live: false) }
  scope :all_in_order, -> { order(:qualification_id, :sorting_order) }
  scope :all_with_exam_sections_enabled, -> { where(enable_exam_sections: true) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first
  end

  def self.search(search)
    if search
      where('name ILIKE ?', "%#{search}%")
    else
      ExamLevel.all_active.where(enable_exam_sections: false )
    end
  end

  # instance methods
  def active_children
    self.children.all_active.all_in_order
  end

  def children
    if self.enable_exam_sections
      self.exam_sections.all
    else
      self.course_modules.all
    end
  end

  def completed_by_user_or_guid(user_id, session_guid)
    self.percentage_complete_by_user_or_guid(user_id, session_guid) == 100
  end

  def destroyable?
    !self.active && self.exam_sections.empty? && self.course_modules.empty? && self.student_exam_tracks.empty? && self.user_exam_level.empty?
  end

  def first_active_cme
    self.active_children.first.try(:first_active_cme)
  end

  def full_name
    self.qualification.name + ' > ' + self.name
  end

  def number_complete_by_user_or_guid(user_id, session_guid)
    self.student_exam_tracks.for_user_or_session(user_id, session_guid).sum(:count_of_cmes_completed)
  end

  def parent
    self.qualification
  end

  def percentage_complete_by_user_or_guid(user_id, session_guid)
    if self.cme_count > 0
      (self.number_complete_by_user_or_guid(user_id, session_guid).to_f / self.cme_count.to_f * 100).to_i
    else
      0
    end
  end

  protected

  def calculate_best_possible_score
    self.best_possible_first_attempt_score = self.course_module_element_quizzes.sum(:best_possible_score_first_attempt)
  end

  def recalculate_cme_count
    self.cme_count = self.active_children.sum(:cme_count)
  end

  def recalculate_duration
    if self.enable_exam_sections
      self.duration = self.active_children.sum(:duration)
    else
      self.duration = self.active_children.sum(:estimated_time_in_seconds)
    end
  end

end
