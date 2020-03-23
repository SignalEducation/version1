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
#  address_line1       :string(255)
#  account_country     :string(255)
#  account_country_id  :integer
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
#  is_default_card     :boolean          default("false")
#  address_line2       :string(255)
#  address_city        :string(255)
#  address_state       :string(255)
#  address_zip         :string(255)
#  address_country     :string(255)
#

class SubscriptionPaymentCard < ApplicationRecord
  include LearnSignalModelExtras

  # Constants
  STATUSES = %w(card-live not-live expired)

  # relationships
  has_many :charges
  belongs_to :user
  belongs_to :account_address_country, class_name: 'Country',
             foreign_key: :account_country_id

  # validation
  validates :user_id, presence: true
  validates :stripe_card_guid, presence: true, length: { maximum: 255 }
  validates :status, inclusion: {in: STATUSES}, length: { maximum: 255 }
  validates :brand, presence: true, length: { maximum: 255 }
  validates :last_4, presence: true, length: { maximum: 255 }
  validates :expiry_month, presence: true
  validates :expiry_year, presence: true
  validates_length_of :address_line1, maximum: 255, allow_blank: true
  validates_length_of :account_country, maximum: 255, allow_blank: true
  validates_length_of :stripe_object_name, maximum: 255, allow_blank: true
  validates_length_of :funding, maximum: 255, allow_blank: true
  validates_length_of :cardholder_name, maximum: 255, allow_blank: true
  validates_length_of :fingerprint, maximum: 255, allow_blank: true
  validates_length_of :cvc_checked, maximum: 255, allow_blank: true
  validates_length_of :address_line1_check, maximum: 255, allow_blank: true
  validates_length_of :address_zip_check, maximum: 255, allow_blank: true
  validates_length_of :dynamic_last4, maximum: 255, allow_blank: true
  validates_length_of :customer_guid, maximum: 255, allow_blank: true
  validates_length_of :address_line2, maximum: 255, allow_blank: true
  validates_length_of :address_city, maximum: 255, allow_blank: true
  validates_length_of :address_state, maximum: 255, allow_blank: true
  validates_length_of :address_zip, maximum: 255, allow_blank: true
  validates_length_of :address_country, maximum: 255, allow_blank: true

  # callbacks
  # Only if user adding another card not if creating with subscription
  before_validation :create_on_stripe_using_token, on: :create, if: :stripe_token
  # Only if user adding another card not if creating with subscription
  after_create :update_stripe_and_other_cards, if: :stripe_token
  # Only if creation from subscription creation
  after_create :delete_existing_default_cards, unless: :stripe_token

  before_destroy :remove_card_from_stripe

  # scopes

  scope :all_in_order, -> { order(:user_id, :status) }
  scope :all_default_cards, -> { where(is_default_card: true) }

  # class methods
  def self.build_from_stripe_data(stripe_card_data, user_id = nil)
    user = User.find(user_id)
    country_id = Country.find_by_iso_code(stripe_card_data[:country].to_s.upcase).try(:id) || user.try(:country_id)
    x = SubscriptionPaymentCard.new(
        user_id: user.id,
        stripe_card_guid: stripe_card_data[:id],
        brand: stripe_card_data[:brand],
        last_4: stripe_card_data[:last4],
        expiry_month: stripe_card_data[:exp_month],
        expiry_year: stripe_card_data[:exp_year],
        address_line1: stripe_card_data[:address_line1],
        address_line2: stripe_card_data[:address_line2],
        address_city: stripe_card_data[:address_city],
        address_zip: stripe_card_data[:address_zip],
        address_state: stripe_card_data[:address_state],
        address_country: stripe_card_data[:address_country],
        account_country: stripe_card_data[:country],
        account_country_id: country_id,
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
        status: 'card-live'
    )

    unless x.save
      Rails.logger.error "SubscriptionPaymentCard#build_from_stripe_data - failed to save a new record. Errors: #{x.errors.inspect}"
    end
  end

  # AfterCreate callback from Subscription model
  def self.create_from_stripe_array(stripe_card_array, user_id, default_card_guid)

    old_default_cards = SubscriptionPaymentCard.where(user_id: user_id, is_default_card: true)
    # Delete any previous default cards
    old_default_cards.each do |card|
      card.destroy
    end

    stripe_card_array.each do |data_item|
      # Loop through the stripe array of existing cards if one is equal to the new default_card id then create a card record for it
      if data_item[:object] == 'card' && data_item[:id] == default_card_guid
        SubscriptionPaymentCard.build_from_stripe_data(data_item, user_id)
      end
    end
  end

  # instance methods

  def create_on_stripe_using_token
    if self.stripe_token.to_s.length > 0 && self.user.stripe_customer_id && self.stripe_card_guid.blank?
      stripe_customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
      new_card_hash = stripe_customer.sources.create({source: self.stripe_token}).to_hash

      if stripe_customer && new_card_hash
        self.stripe_card_guid = new_card_hash[:id]
        self.status = (new_card_hash[:cvc_check] == 'pass') ? 'card-live' : 'not-live'
        self.brand = new_card_hash[:brand]
        self.last_4 = new_card_hash[:last4]
        self.expiry_month = new_card_hash[:exp_month]
        self.expiry_year = new_card_hash[:exp_year]
        self.address_line1 = new_card_hash[:address_line_1]
        self.address_line2 = new_card_hash[:address_line_2]
        self.address_city = new_card_hash[:address_city]
        self.address_state = new_card_hash[:address_state]
        self.address_zip = new_card_hash[:address_zip]
        self.address_country = new_card_hash[:address_country]
        self.account_country = new_card_hash[:country]
        self.account_country_id = Country.find_by_iso_code(new_card_hash[:country].upcase).id
        self.stripe_object_name = new_card_hash[:object]
        self.funding = new_card_hash[:funding]
        self.cardholder_name = new_card_hash[:name]
        self.fingerprint = new_card_hash[:fingerprint]
        self.cvc_checked = new_card_hash[:cvc_check]
        self.address_line1_check = new_card_hash[:address_line1_check]
        self.address_zip_check = new_card_hash[:address_zip_check]
        self.dynamic_last4 = new_card_hash[:dynamic_last4]
        self.customer_guid = new_card_hash[:customer]
        self.is_default_card = true
      else
        Rails.logger.error "ERROR: Could not find Stripe Customer with-#{self.user.stripe_customer_id}. OR Stripe Create card failed with response-#{new_card_hash}."
      end
    else
      Rails.logger.error "ERROR: Could not find Stripe Token-#{self.stripe_token} OR a customer id in the User-#{self.user.stripe_customer_id}"
    end

  rescue Stripe::CardError => e
    body = e.json_body
    err = body[:error]

    Rails.logger.error "DEBUG: SubPaymentCard#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"

    errors.add(:base, "Sorry! Your card was declined because - #{err[:message]}")
    false

  rescue => e
    Rails.logger.error "ERROR: SubscriptionPaymentCard#create_on_stripe_using_token - error: #{e.inspect}.  Self: #{self.inspect}."
    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    false
  end

  def destroyable?
    # don't allow destroy if it is the default card or if user has a current valid subscription
    !is_default_card || !user.current_subscription?
  end

  def status
    unless self.read_attribute(:status) == 'expired'
      if self.expiry_year && self.expiry_month
        expires_on = Date.new(self.expiry_year, self.expiry_month, 1) + 1.month
        if expires_on < proc {Time.now}.call && self.id.nil?
          self.assign_attributes(status: 'expired')
        elsif expires_on < proc {Time.now}.call
          self.update_column(:status, 'expired')
        end
      end
    end
    self.read_attribute(:status)
  end


  def stripe_token=(t)
    @stripe_token = t
  end

  def stripe_token
    @stripe_token
  end

  def update_as_the_default_card
    if self.status == 'expired'
      errors.add(:base, I18n.t('models.subscription_payment_cards.card_has_expired'))
      false
    else
      # mark the current live card(s) as not-live
      SubscriptionPaymentCard.where(user_id: self.user_id, status: 'card-live').update_all(status: 'not-live', is_default_card: false)
      # mark the target card as live / default
      self.update_columns(status: 'card-live', is_default_card: true)
      # Update the stripe customers default source to be this card
      stripe_customer = Stripe::Customer.retrieve(self.customer_guid)
      stripe_customer.default_source = self.stripe_card_guid
      stripe_customer.save
    end
    true
  rescue => e
    Rails.logger.error "ERROR: SubscriptionPaymentCard#update_default_card failed. Error: #{e.inspect}. Self: #{self.errors.inspect}"
    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    false
  end

  def expiry_date
    expiry_month.to_s + '/' + expiry_year.to_s
  end

  protected

  def remove_card_from_stripe
    stripe_customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    stripe_card = stripe_customer.sources.retrieve(self.stripe_card_guid)
    response = stripe_card.delete
    if response[:deleted]
      true
    else
      errors.add(:base, 'Stripe could not delete the card')
      false
    end

  rescue => e
    if e.response.data[:error][:message] == "No such source: #{self.stripe_card_guid}"
      true
    else
      Rails.logger.error "ERROR: SubscriptionPaymentCard#delete_card failed. Error: #{e.inspect}. Self: #{self.errors.inspect}"
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
      false
    end
  end

  def update_stripe_and_other_cards
    # Ensure only the new card record is default, all other existing records are updated to default: false
    stripe_customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    stripe_customer.default_source = self.stripe_card_guid
    stripe_customer.save

    other_cards = SubscriptionPaymentCard.where(user_id: self.user_id, is_default_card: true).where.not(id: self.id)
    other_cards.update_all(status: 'not-live', is_default_card: false)
  end

  def delete_existing_default_cards
    # Delete all default cards without triggering callbacks - stripe deletes when default source changes

    other_cards = SubscriptionPaymentCard.where(user_id: self.user_id, is_default_card: true).where.not(id: self.id)
    other_cards.delete_all

  end


end
