# == Schema Information
#
# Table name: user_groups
#
#  id                                   :integer          not null, primary key
#  name                                 :string(255)
#  description                          :text
#  individual_student                   :boolean          default(FALSE), not null
#  corporate_student                    :boolean          default(FALSE), not null
#  tutor                                :boolean          default(FALSE), not null
#  content_manager                      :boolean          default(FALSE), not null
#  blogger                              :boolean          default(FALSE), not null
#  corporate_customer                   :boolean          default(FALSE), not null
#  site_admin                           :boolean          default(FALSE), not null
#  forum_manager                        :boolean          default(FALSE), not null
#  subscription_required_at_sign_up     :boolean          default(FALSE), not null
#  subscription_required_to_see_content :boolean          default(FALSE), not null
#  created_at                           :datetime
#  updated_at                           :datetime
#

class UserGroup < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :description, :individual_student, :tutor, :content_manager,
                  :blogger, :corporate_customer, :site_admin, :forum_manager,
                  :subscription_required_at_sign_up, :corporate_student,
                  :subscription_required_to_see_content

  # Constants
  FEATURES = %w(individual_student tutor corporate_student corporate_customer blogger forum_manager content_manager admin)

  # relationships
  has_many :users

  # validation
  validates :name, presence: true, uniqueness: true
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
