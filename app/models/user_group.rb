# == Schema Information
#
# Table name: user_groups
#
#  id                                   :integer          not null, primary key
#  name                                 :string
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
#  complimentary                        :boolean          default(FALSE)
#

class UserGroup < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :description, :individual_student, :tutor, :content_manager,
                  :blogger, :corporate_customer, :site_admin, :forum_manager,
                  :subscription_required_at_sign_up, :corporate_student,
                  :subscription_required_to_see_content, :complimentary
  # Constants
  FEATURES = %w(individual_student tutor corporate_student corporate_customer blogger forum_manager content_manager admin complimentary)
  CORPORATE_STUDENTS = 2
  CORPORATE_CUSTOMERS = 3

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
  def self.default_admin_user_group
    where(site_admin: true).first
  end

  def self.default_complimentary_user_group
    where(individual_student: false, complimentary: true, site_admin: false, subscription_required_at_sign_up: false, subscription_required_to_see_content: false).first
  end

  def self.default_student_user_group
    where(individual_student: true, complimentary: false, corporate_student: false, tutor: false, content_manager: false, blogger: false, corporate_customer: false, site_admin: false, forum_manager: false, subscription_required_at_sign_up: true, subscription_required_to_see_content: true).first
  end

  def self.default_tutor_user_group
    where(individual_student: false, complimentary: false, corporate_student: false, tutor: true, content_manager: false, blogger: false, corporate_customer: false, site_admin: false, subscription_required_at_sign_up: false, subscription_required_to_see_content: false).first
  end

  def self.default_corporate_student_user_group
    where(individual_student: false, complimentary: false, corporate_student: true, tutor: false, content_manager: false, blogger: false, corporate_customer: false, site_admin: false, subscription_required_at_sign_up: false, subscription_required_to_see_content: false).first
  end

  def self.default_corporate_customer_user_group
    where(individual_student: false, complimentary: false, corporate_student: false, tutor: true, content_manager: false, blogger: false, corporate_customer: true, site_admin: false, subscription_required_at_sign_up: false, subscription_required_to_see_content: false).first
  end

  # instance methods
  def destroyable?
    self.users.empty?
  end

  protected

end
