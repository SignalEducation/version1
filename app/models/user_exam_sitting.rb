# == Schema Information
#
# Table name: user_exam_sittings
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  exam_sitting_id   :integer
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class UserExamSitting < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :exam_sitting_id, :subject_course_id, :date

  # Constants

  # relationships
  belongs_to :user
  belongs_to :exam_sitting
  belongs_to :subject_course

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_sitting_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :date, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
