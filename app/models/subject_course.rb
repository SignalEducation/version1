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
#

class SubjectCourse < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :name_url, :sorting_order, :active, :live, :wistia_guid, :tutor_id, :cme_count, :description, :short_description, :mailchimp_guid, :forum_url, :default_number_of_possible_exam_answers

  # Constants

  # relationships
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  has_many :course_modules
  has_many :course_module_elements, through: :course_modules
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :course_module_jumbo_quizzes, through: :course_modules
  has_many :question_banks
  has_many :student_exam_tracks
  has_many :corporate_group_grants

  # validation
  validates :name, presence: true, length: {maximum: 255}
  validates :name_url, presence: true,
            length: {maximum: 255}
  validates :wistia_guid, presence: true, length: {maximum: 255}
  validates :tutor_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :description, presence: true
  validates :short_description, presence: true, length: {maximum: 255}
  validates :mailchimp_guid, presence: true, length: {maximum: 255}
  validates :forum_url, presence: true, length: {maximum: 255}
  validates :default_number_of_possible_exam_answers, presence: true, numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_validation { squish_fields(:name, :name_url) }
  before_create :set_sorting_order
  before_save :calculate_best_possible_score
  before_save :sanitize_name_url
  before_save :recalculate_cme_count
  before_destroy :check_dependencies

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_live, -> { where(live: true) }
  scope :all_not_live, -> { where(live: false) }
  scope :all_in_order, -> { order(:sorting_order, :name) }

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
    !self.active && self.course_modules.empty? && self.student_exam_tracks.empty?
  end

  def first_active_cme
    self.active_children.first.try(:first_active_cme)
  end

  def full_name
    #self.qualification.name + ' > ' + self.name
  end

  def number_complete_by_user_or_guid(user_id, session_guid)
    self.student_exam_tracks.for_user_or_session(user_id, session_guid).sum(:count_of_cmes_completed)
  end

  def parent
    #self.path
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

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
