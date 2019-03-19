# == Schema Information
#
# Table name: exam_bodies
#
#  id            :integer          not null, primary key
#  name          :string
#  url           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  modal_heading :string
#  modal_text    :text
#

class ExamBody < ActiveRecord::Base
  has_many :enrollments
  has_many :exam_sittings
  has_many :subject_courses
  has_many :exam_body_user_details
  has_many :subscription_plans

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true

  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }

  # instance methods
  def destroyable?
    self.exam_sittings.empty? && self.enrollments.empty? && self.subject_courses.empty?
  end

  def to_s
    name
  end

  private

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end
end
