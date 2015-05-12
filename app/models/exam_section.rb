# == Schema Information
#
# Table name: exam_sections
#
#  id                                :integer          not null, primary key
#  name                              :string(255)
#  name_url                          :string(255)
#  exam_level_id                     :integer
#  active                            :boolean          default(FALSE), not null
#  sorting_order                     :integer
#  best_possible_first_attempt_score :float
#  created_at                        :datetime
#  updated_at                        :datetime
#  cme_count                         :integer          default(0)
#  seo_description                   :string(255)
#  seo_no_index                      :boolean          default(FALSE)
#  duration                          :integer
#

class ExamSection < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :name_url, :exam_level_id, :active, :sorting_order,
                  :seo_description, :seo_no_index, :duration

  # Constants

  # relationships
  belongs_to :exam_level
  has_many :course_modules
  has_many :course_module_elements, through: :course_modules
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :student_exam_tracks

  # validation
  validates :name, presence: true
  validates :name_url, presence: true, uniqueness: true
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true

  # callbacks
  before_validation { squish_fields(:name, :name_url) }
  before_create :set_sorting_order
  before_save :calculate_best_possible_score
  before_save :sanitize_name_url
  before_save :recalculate_cme_count
  before_save :recalculate_duration
  after_commit :recalculate_parent

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :with_url, lambda { |the_url| where(name_url: the_url) }

  # class methods

  # instance methods
  def active_children
    self.children.all_active.all_in_order
  end

  def children
    self.course_modules
  end

  def completed_by_user_or_guid(user_id, session_guid)
    self.percentage_complete_by_user_or_guid(user_id, session_guid) == 100
  end

  def destroyable?
    !self.active && self.course_modules.empty? && self.student_exam_tracks.empty?
  end

  def first_active_cme
    self.active_children.first.try(:first_active_cme)
  end

  def full_name
    self.exam_level.name + ' > ' + self.name
  end

  def number_complete_by_user_or_guid(user_id, session_guid)
    self.student_exam_tracks.for_user_or_session(user_id, session_guid).sum(:count_of_cmes_completed)
  end

  def parent
    self.exam_level
  end

  def percentage_complete_by_user_or_guid(user_id, session_guid)
    if self.cme_count > 0
      (self.number_complete_by_user_or_guid(user_id, session_guid).to_f / self.cme_count.to_f * 100).to_i
    else
      0
    end
  end

  def total_active_cmes
    self.active_children.sum(:cme_count)
  end

  protected

  def calculate_best_possible_score
    self.best_possible_first_attempt_score = self.course_module_element_quizzes.sum(:best_possible_score_first_attempt)
  end

  def recalculate_cme_count
    self.cme_count = self.total_active_cmes
    true
  end

  def recalculate_parent
    changes_1 = self.previous_changes[:cme_count] # [prev,new]
    changes_2 = self.previous_changes[:duration] # [prev,new]
    if (changes_1 && changes_1[0] != changes_1[1]) || (changes_2 && changes_2[0] != changes_2[1])
      self.parent.save
    end
  end

  def recalculate_duration
    self.duration = self.active_children.sum(:estimated_time_in_seconds)
  end

end
