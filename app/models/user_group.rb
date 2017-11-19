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

  # class methods

  # instance methods
  def destroyable?
    self.users.empty?
  end

  protected

end
