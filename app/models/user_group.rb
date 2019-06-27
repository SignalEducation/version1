# == Schema Information
#
# Table name: user_groups
#
#  id                           :integer          not null, primary key
#  name                         :string
#  description                  :text
#  tutor                        :boolean          default(FALSE), not null
#  site_admin                   :boolean          default(FALSE), not null
#  created_at                   :datetime
#  updated_at                   :datetime
#  system_requirements_access   :boolean          default(FALSE)
#  content_management_access    :boolean          default(FALSE)
#  stripe_management_access     :boolean          default(FALSE)
#  user_management_access       :boolean          default(FALSE)
#  developer_access             :boolean          default(FALSE)
#  user_group_management_access :boolean          default(FALSE)
#  student_user                 :boolean          default(FALSE)
#  trial_or_sub_required        :boolean          default(FALSE)
#  blocked_user                 :boolean          default(FALSE)
#  marketing_resources_access   :boolean          default(FALSE)
#  exercise_corrections_access  :boolean          default(FALSE)
#

class UserGroup < ApplicationRecord
  include LearnSignalModelExtras

  # Constants

  # relationships
  has_many :users

  # validation
  validates :name, presence: true, uniqueness: true, length: { maximum: 255}
  validates :description, presence: true

  # callbacks
  before_validation { squish_fields(:name, :description) }

  # scopes
  scope :all_in_order, -> { order(:name) }
  scope :all_not_student, -> { where(student_user: false) }
  scope :all_not_admin, -> { where(site_admin: false) }
  scope :all_student, -> { where(student_user: true) }
  scope :all_trial_or_sub, -> { where(trial_or_sub_required: true) }

  # class methods

  def self.student_group
    self.where(student_user: true, trial_or_sub_required: true).first
  end

  # instance methods
  def destroyable?
    self.users.empty?
  end
end
