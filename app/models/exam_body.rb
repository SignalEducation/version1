# == Schema Information
#
# Table name: exam_bodies
#
#  id         :integer          not null, primary key
#  name       :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExamBody < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :url

  # Constants

  # relationships
  has_many :enrollments
  has_many :subject_courses
  has_many :exam_sittings

  # validation
  validates :name, presence: true, uniqueness: true
  validates :url, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }

  # class methods

  # instance methods
  def destroyable?
    true
    self.exam_sittings.empty? && self.enrollments.empty? && self.subject_courses.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
