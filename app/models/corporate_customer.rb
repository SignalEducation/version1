# == Schema Information
#
# Table name: corporate_customers
#
#  id                   :integer          not null, primary key
#  organisation_name    :string
#  address              :text
#  country_id           :integer
#  payments_by_card     :boolean          default(FALSE), not null
#  stripe_customer_guid :string
#  created_at           :datetime
#  updated_at           :datetime
#  logo_file_name       :string
#  logo_content_type    :string
#  logo_file_size       :integer
#  logo_updated_at      :datetime
#  subdomain            :string
#  user_name            :string
#  passcode             :string
#  external_url         :string
#  footer_border_colour :string           default("#EFF3F6")
#  corporate_email      :string
#  external_logo_link   :boolean          default(FALSE)
#

class CorporateCustomer < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :organisation_name, :address, :country_id, :payments_by_card,
                  :stripe_customer_guid, :logo, :subdomain, :user_name, :passcode, :external_url,
                  :footer_border_colour, :corporate_email, :external_logo_link

  # Constants

  # relationships
  belongs_to :country
  has_many :course_module_element_user_logs
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
  has_attached_file :logo, default_url: "missing_corporate_logo.png"

  # validation
  validates :organisation_name, presence: true, length: {maximum: 255}
  validates :subdomain, presence: true, uniqueness: true, length: {maximum: 20}
  validates :user_name, presence: true, length: {maximum: 25}
  validates :passcode, presence: true, length: {maximum: 25}
  validates :corporate_email, presence: true
  validates :external_url, presence: true
  #validates :logo, presence: true
  validates :footer_border_colour, presence: true, length: {maximum: 25}
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_validation { squish_fields(:organisation_name, :address) }
  #after_create :create_on_intercom

  # scopes
  scope :all_in_order, -> { order(:organisation_name) }

  # class methods

  # instance methods
  def destroyable?
    self.students.empty? &&
      self.managers.empty? &&
      self.course_module_element_user_logs.empty?
  end

  def create_on_intercom
    unless Rails.env.test?
      IntercomCreateCompanyWorker.perform_async(self.id, self.organisation_name)
    end
  end

  protected

end
