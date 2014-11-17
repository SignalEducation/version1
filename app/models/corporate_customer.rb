# == Schema Information
#
# Table name: corporate_customers
#
#  id                   :integer          not null, primary key
#  organisation_name    :string(255)
#  address              :text
#  country_id           :integer
#  payments_by_card     :boolean          default(FALSE), not null
#  is_university        :boolean          default(FALSE), not null
#  owner_id             :integer
#  stripe_customer_guid :string(255)
#  can_restrict_content :boolean          default(FALSE), not null
#  created_at           :datetime
#  updated_at           :datetime
#

class CorporateCustomer < ActiveRecord::Base

  # attr-accessible
  attr_accessible :organisation_name, :address, :country_id, :payments_by_card,
                  :is_university, :owner_id, :stripe_customer_guid,
                  :can_restrict_content

  # Constants

  # relationships
  # todo belongs_to :country
  has_many :course_module_element_user_logs
  # todo has_many :corporate_customer_prices
  # todo has_many :corporate_customer_users
  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
  has_many :students, class_name: 'User', foreign_key: :corporate_customer_id

  # validation
  validates :organisation_name, presence: true
  validates :address, presence: true
  validates :country_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :owner_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:organisation_name) }

  # class methods

  # instance methods
  def destroyable?
    self.students.empty? # todo && self.corporate_customer_prices.empty? && self.corporate_customer_users.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
