# == Schema Information
#
# Table name: user_groups
#
#  id                 :integer          not null, primary key
#  name               :string
#  description        :text
#  individual_student :boolean          default(FALSE), not null
#  tutor              :boolean          default(FALSE), not null
#  content_manager    :boolean          default(FALSE), not null
#  blogger            :boolean          default(FALSE), not null
#  site_admin         :boolean          default(FALSE), not null
#  created_at         :datetime
#  updated_at         :datetime
#  complimentary      :boolean          default(FALSE)
#  customer_support   :boolean          default(FALSE)
#  marketing_support  :boolean          default(FALSE)
#

class UserGroup < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :description, :individual_student, :tutor, :content_manager,
                  :blogger, :site_admin, :complimentary, :customer_support,
                  :marketing_support
  # Constants
  FEATURES = %w(individual_student tutor blogger content_manager admin complimentary customer_support_manager marketing_manager)

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
    where(individual_student: false, complimentary: true, site_admin: false,customer_support: false, marketing_support: false).first
  end

  def self.default_student_user_group
    where(individual_student: true, complimentary: false, tutor: false, content_manager: false, blogger: false, site_admin: false).first
  end

  def self.default_tutor_user_group
    where(individual_student: false, complimentary: true, tutor: true, content_manager: false, blogger: false, site_admin: false).first
  end

  def self.default_content_manager_user_group
    where(individual_student: false, complimentary: true, tutor: false, content_manager: true, blogger: false, site_admin: false).first
  end

  def self.default_customer_support_user_group
    where(individual_student: false, complimentary: true, tutor: false, content_manager: false, blogger: false, site_admin: false, customer_support: true, marketing_support: false).first
  end

  def self.default_marketing_support_user_group
    where(individual_student: false, complimentary: true, tutor: false, content_manager: false, blogger: false, site_admin: false, customer_support: false, marketing_support: true).first
  end

  # instance methods
  def destroyable?
    self.users.empty?
  end

  protected

end
