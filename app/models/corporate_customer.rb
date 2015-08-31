# == Schema Information
#
# Table name: corporate_customers
#
#  id                   :integer          not null, primary key
#  created_at           :datetime
#  updated_at           :datetime
#  organisation_name    :string
#  address              :text
#  country_id           :integer
#  payments_by_card     :boolean          default(FALSE), not null
#  stripe_customer_guid :string
#  logo_file_name       :string
#  logo_content_type    :string
#  logo_file_size       :integer
#  logo_updated_at      :datetime
#

class CorporateCustomer < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :organisation_name, :address, :country_id, :payments_by_card,
                  :stripe_customer_guid, :logo

  # Constants

  # relationships
  belongs_to :country
  has_many :course_module_element_user_logs
  # todo has_many :corporate_customer_prices
  # todo has_many :corporate_customer_users
  has_many :invoices
  has_many :students,
           -> { where(user_group_id: UserGroup::CORPORATE_STUDENTS) },
           class_name: 'User',
           foreign_key: :corporate_customer_id
  has_many :managers,
           -> { where(user_group_id: UserGroup::CORPORATE_CUSTOMERS)},
           class_name: 'User',
           foreign_key: :corporate_customer_id
  has_many :subscriptions
  has_many :corporate_groups
  has_attached_file :logo, default_url: "/assets/images/placeholder-company.gif"

  # validation
  validates :organisation_name, presence: true, length: {maximum: 255}
  validates :address, presence: true
  validates :country_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_validation { squish_fields(:organisation_name, :address) }

  # scopes
  scope :all_in_order, -> { order(:organisation_name) }

  # class methods

  # instance methods
  def destroyable?
    self.students.empty? &&
      self.managers.empty? &&
      self.course_module_element_user_logs.empty? &&
      self.invoices.empty? &&
      self.subscriptions.empty?
  end

  protected

end
