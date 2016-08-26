# == Schema Information
#
# Table name: enrollments
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  subject_course_id          :integer
#  subject_course_user_log_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class Enrollment < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :subject_course_id, :subject_course_user_log_id

  # Constants

  # relationships
  belongs_to :user
  belongs_to :subject_course
  has_one :subject_course_user_log

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_user_log_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }

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
