# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  stripe_card_guid    :string(255)
#  status              :string(255)
#  brand               :string(255)
#  last_4              :string(255)
#  expiry_month        :integer
#  expiry_year         :integer
#  billing_address     :string(255)
#  billing_country     :string(255)
#  billing_country_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  stripe_object_name  :string(255)
#  funding             :string(255)
#  cardholder_name     :string(255)
#  fingerprint         :string(255)
#  cvc_checked         :string(255)
#  address_line1_check :string(255)
#  address_zip_check   :string(255)
#  dynamic_last4       :string(255)
#  customer_guid       :string(255)
#  is_default_card     :boolean          default(FALSE)
#

class SubscriptionPaymentCard < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :stripe_card_guid, :status,
                  :brand, :last_4, :expiry_month, :expiry_year,
                  :billing_address, :billing_country, :billing_country_id,
                  :stripe_object_name, :funding, :cardholder_name, :fingerprint,
                  :cvc_checked, :address_line1_check, :address_zip_check,
                  :dynamic_last4, :customer_guid, :is_default_card

  # Constants
  STATUSES = %w(live not-live)

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

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    self.subscription_transactions.empty?
  end

  protected

end
