# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  stripe_card_guid   :string(255)
#  status             :string(255)
#  brand              :string(255)
#  last_4             :string(255)
#  expiry_month       :integer
#  expiry_year        :integer
#  billing_address    :string(255)
#  billing_country    :string(255)
#  billing_country_id :integer
#  account_email      :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class SubscriptionPaymentCard < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :stripe_card_guid, :status,
                  :brand, :last_4, :expiry_month, :expiry_year,
                  :billing_address, :billing_country, :billing_country_id,
                  :account_email

  # Constants
  STATUSES = %w(live)

  # relationships
  has_many :subscription_transactions
  belongs_to :user
  belongs_to :billing_country, class_name: 'Country',
             foreign_key: :billing_country_id

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_card_guid, presence: true
  validates :status, inclusion: {in: STATUSES}
  validates :brand, presence: true
  validates :last_4, presence: true
  validates :expiry_month, presence: true
  validates :expiry_year, presence: true
  validates :billing_country_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    self.subscription_transactions.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
