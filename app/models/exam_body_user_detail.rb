# == Schema Information
#
# Table name: exam_body_user_details
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  exam_body_id      :integer
#  student_number    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  subscription_type :string
#

class ExamBodyUserDetail < ApplicationRecord

  # Constants

  # relationships
  belongs_to :user
  belongs_to :exam_body

  # validation
  validates :user_id, presence: true
  validates :exam_body_id, presence: true
  validates :student_number, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :for_user, lambda { |user_id| where(user_id: user_id) }
  scope :for_exam_body, lambda { |exam_body_id| where(exam_body_id: exam_body_id) }

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
