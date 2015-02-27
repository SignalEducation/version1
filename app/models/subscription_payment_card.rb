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
  CHECKING_STATUSES = %w(pass fail unavailable unchecked)

  # relationships
  has_many :subscription_transactions
  belongs_to :user
  belongs_to :billing_address_country, class_name: 'Country',
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
  scope :all_default_cards, -> { where(is_default_card: true) }

  # class methods
  def self.build_from_stripe_data(stripe_card_data, user_id=nil)
    if stripe_card_data[:object] == 'card'
      user_id ||= User.where(stripe_customer_id: stripe_card_data[:customer]).first.try(:id)
      country_id = Country.find_by_iso_code(stripe_card_data[:country].upcase).try(:id)
      x = SubscriptionPaymentCard.new(
              user_id: user_id,
              stripe_card_guid: stripe_card_data[:id],
              brand: stripe_card_data[:brand],
              last_4: stripe_card_data[:last4],
              expiry_month: stripe_card_data[:exp_month],
              expiry_year: stripe_card_data[:exp_year],
              billing_address: stripe_card_data[:address_line1],
              billing_country: stripe_card_data[:country],
              billing_country_id: country_id,
              stripe_object_name: stripe_card_data[:object],
              funding: stripe_card_data[:funding],
              cardholder_name: stripe_card_data[:name],
              fingerprint: stripe_card_data[:fingerprint],
              cvc_checked: stripe_card_data[:cvc_check],
              address_line1_check: stripe_card_data[:address_line1_check],
              address_zip_check: stripe_card_data[:address_zip_check],
              dynamic_last4: stripe_card_data[:dynamic_last4],
              customer_guid: stripe_card_data[:customer],
              is_default_card: true,
              status: 'live'
      )
      unless x.save
        Rails.logger.error "SubscriptionPaymentCard#build_from_stripe_data - failed to save a new record. Errors: #{x.errors.inspect}"
      end
    else
      Rails.logger.error "SubscriptionPaymentCard#build_from_stripe_data - invalid data structure sent into this method.  Incoming data: #{stripe_card_data.inspect}."
    end
  end

  def self.create_cards_from_stripe_array(stripe_card_array, user_id, default_card_guid)
    this_customers_cards = SubscriptionPaymentCard.where(user_id: user_id)

    card_guid_list = this_customers_cards.map(&:stripe_card_guid)
    stripe_card_array.each do |data_item|
      if data_item[:object] == 'card' && !card_guid_list.include?(data_item[:id])
        SubscriptionPaymentCard.build_from_stripe_data(data_item, user_id)
      end
    end
    #### mark the default card as "live"
    this_customers_cards.reload
    if this_customers_cards.length > 1
      this_customers_cards.update_all(is_default_card: false, status: 'not-live')
      the_default_card = this_customers_cards.where(stripe_card_guid: default_card_guid).first
      the_default_card.update_attributes(is_default_card: true, status: 'live')
      return the_default_card.id
    else
      this_customers_cards.first.id
    end
  end

  def self.get_updates_for_user(stripe_customer_guid)
    customer_payload = Stripe::Customer.retrieve(stripe_customer_guid).to_hash
    if customer_payload && customer_payload[:cards]
      user = User.where(stripe_customer_id: stripe_customer_guid).first

      SubscriptionPaymentCard.create_cards_from_stripe_array(customer_payload[:cards][:data], user.id, customer_payload[:default_card])

    else
      Rails.logger.warn "WARN: SubscriptionPaymentCard#get_updates_for_user - couldn't retrieve valid customer data for customer guid #{stripe_customer_guid}"
    end
  end

  # instance methods
  def destroyable?
    self.subscription_transactions.empty?
  end

  protected

end
