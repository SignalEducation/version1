# == Schema Information
#
# Table name: institution_users
#
#  id                          :integer          not null, primary key
#  institution_id              :integer
#  user_id                     :integer
#  student_registration_number :string(255)
#  student                     :boolean          default(FALSE), not null
#  qualified                   :boolean          default(FALSE), not null
#  created_at                  :datetime
#  updated_at                  :datetime
#  exam_number                 :string(255)
#  membership_number           :string(255)
#

class InstitutionUser < ActiveRecord::Base

  # attr-accessible
  attr_accessible :institution_id, :user_id, :student_registration_number, :student, :qualified

  # Constants

  # relationships
  belongs_to :institution
  belongs_to :user

  # validation
  validates :institution_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validate :require_student_id_if_student

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:institution_id, :user_id) }

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

  def require_student_id_if_student
    if self.student && self.student_registration_number.blank?
      errors.add(:student_registration_number, I18n.t('models.institution_users.can_t_be_blank_for_students'))
    end
  end

end
