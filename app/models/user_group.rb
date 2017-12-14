# == Schema Information
#
# Table name: user_groups
#
#  id                           :integer          not null, primary key
#  name                         :string
#  description                  :text
#  individual_student           :boolean          default(FALSE), not null
#  tutor                        :boolean          default(FALSE), not null
#  content_manager              :boolean          default(FALSE), not null
#  blogger                      :boolean          default(FALSE), not null
#  site_admin                   :boolean          default(FALSE), not null
#  created_at                   :datetime
#  updated_at                   :datetime
#  complimentary                :boolean          default(FALSE)
#  customer_support             :boolean          default(FALSE)
#  marketing_support            :boolean          default(FALSE)
#  system_requirements_access   :boolean          default(FALSE)
#  content_management_access    :boolean          default(FALSE)
#  stripe_management_access     :boolean          default(FALSE)
#  user_management_access       :boolean          default(FALSE)
#  developer_access             :boolean          default(FALSE)
#  home_pages_access            :boolean          default(FALSE)
#  user_group_management_access :boolean          default(FALSE)
#  student_user                 :boolean          default(FALSE)
#  trial_or_sub_required        :boolean          default(FALSE)
#  blocked_user                 :boolean          default(FALSE)
#

class UserGroup < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :description, :system_requirements_access,
                  :content_management_access, :stripe_management_access,
                  :user_management_access, :developer_access,
                  :home_pages_access, :user_group_management_access,
                  :student_user, :trial_or_sub_required, :blocked_user,
                  :tutor
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
  scope :all_student, -> { where(student_user: true) }
  scope :all_trial_or_sub, -> { where(trial_or_sub_required: true) }

  # class methods

  # instance methods
  def destroyable?
    self.users.empty?
  end

  def set_new_attributes
    if self.site_admin
      self.system_requirements_access = true
      self.content_management_access = true
      self.stripe_management_access = true
      self.user_management_access = true
      self.developer_access = true
      self.user_group_management_access = true

    elsif self.content_manager
      self.content_management_access = true

    elsif self.complimentary
      self.student_user = true
      self.trial_or_sub_required = false
      self.blocked_user = false

    elsif self.customer_support
      self.content_management_access = true
      self.user_management_access = true

    elsif self.marketing_support
      self.home_pages_access = true

    elsif self.individual_student
      self.student_user = true
      self.trial_or_sub_required = true

    elsif self.name == 'Blocked User'
      self.student_user = true
      self.trial_or_sub_required = true
      self.blocked_user = true
    end

    self.save
  end

  protected

end
