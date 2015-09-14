# == Schema Information
#
# Table name: subject_courses
#
#  id                :integer          not null, primary key
#  name              :string
#  name_url          :string
#  sorting_order     :integer
#  active            :boolean          default(FALSE), not null
#  live              :boolean          default(FALSE), not null
#  wistia_guid       :string
#  tutor_id          :integer
#  cme_count         :integer
#  video_count       :integer
#  quiz_count        :integer
#  question_count    :integer
#  description       :text
#  short_description :string
#  mailchimp_guid    :string
#  forum_url         :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SubjectCourse < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :name_url, :sorting_order, :active, :live, :wistia_guid, :tutor_id, :cme_count, :description, :short_description, :mailchimp_guid, :forum_url

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

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_live, -> { where(live: true) }
  scope :all_not_live, -> { where(live: false) }
  scope :all_in_order, -> { order(:sorting_order, :name) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
