# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  stripe_card_guid    :string
#  status              :string
#  brand               :string
#  last_4              :string
#  expiry_month        :integer
#  expiry_year         :integer
#  address_line1       :string
#  account_country     :string
#  account_country_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  stripe_object_name  :string
#  funding             :string
#  cardholder_name     :string
#  fingerprint         :string
#  cvc_checked         :string
#  address_line1_check :string
#  address_zip_check   :string
#  dynamic_last4       :string
#  customer_guid       :string
#  is_default_card     :boolean          default(FALSE)
#  address_line2       :string
#  address_city        :string
#  address_state       :string
#  address_zip         :string
#  address_country     :string
#

class SubscriptionPaymentCard < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :stripe_card_guid, :status,
                  :brand, :last_4, :expiry_month, :expiry_year,
                  :address_line1, :address_line2, :address_city,
                  :address_state, :address_zip, :address_country,
                  :account_country, :account_country_id,
                  :stripe_object_name, :funding, :cardholder_name, :fingerprint,
                  :cvc_checked, :address_line1_check, :address_zip_check,
                  :dynamic_last4, :customer_guid, :is_default_card,
                  :stripe_token, :make_default_card

  # Constants
  STATUSES = %w(card-live not-live expired)
  CHECKING_STATUSES = %w(pass fail unavailable unchecked)

  # relationships
  has_many :subscription_transactions
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
  before_validation :create_on_stripe_using_token, on: :create, if: :stripe_token
  after_create :update_as_the_default_card, if: :is_default_card
  before_destroy :remove_card_from_stripe

  # scopes

  scope :all_in_order, -> { order(:user_id, :status) }
  scope :all_default_cards, -> { where(is_default_card: true) }

  # class methods
  def self.build_from_stripe_data(stripe_card_data, user_id=nil)
    if stripe_card_data[:object] == 'card'
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
    the_default_card = this_customers_cards.where(stripe_card_guid: default_card_guid).first
    the_default_card.update_as_the_default_card

    return the_default_card.id || this_customers_cards.last.try(:id)

  end

  # This should not loop. Create from stripe card object created with subscription token
  #
  #
  def self.create_from_stripe_array(stripe_card_array, user_id)
    this_customers_cards = SubscriptionPaymentCard.where(user_id: user_id)
    stripe_card_array.each do |data_item|
      if data_item[:object] == 'card'
        SubscriptionPaymentCard.build_from_stripe_data(data_item, user_id)
      end
    end

    # Delete the all previous existing cards
    this_customers_cards.each do |card|
      card.destroy unless card.is_default_card
    end

  end

  # instance methods

  def create_on_stripe_using_token
    if self.stripe_token.to_s.length > 0 && self.user.stripe_customer_id && self.stripe_card_guid.blank?
      stripe_customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
      new_card_hash = stripe_customer.sources.create({source: self.stripe_token}).to_hash
      if stripe_customer && new_card_hash
        self.stripe_card_guid = new_card_hash[:id]
        self.status = (new_card_hash[:cvc_check] == 'pass' && self.make_default_card) ? 'card-live' : 'not-live'
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
        self.is_default_card = self.make_default_card
      else
        Rails.logger.error "ERROR: Could not find Stripe Customer with-#{self.user.stripe_customer_id}. OR Stripe Create card failed with response-#{new_card_hash}."
      end
    else
      Rails.logger.error "ERROR: Could not find Stripe Token-#{self.stripe_token} OR a customer id in the User-#{self.user.stripe_customer_id}"
    end

  rescue => e
    Rails.logger.error "ERROR: SubscriptionPaymentCard#create_on_stripe_using_token - error: #{e.inspect}.  Self: #{self.inspect}."
    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    false
  end

  def destroyable?
    !self.is_default_card?
  end

  def make_default_card=(t)
    @make_default_card = t
  end

  def make_default_card
    @make_default_card
  end

  def status
    unless self.read_attribute(:status) == 'expired'
      if self.expiry_year && self.expiry_month
        expires_on = Date.new(self.expiry_year, self.expiry_month, 1) + 1.month
        if expires_on < Proc.new{Time.now}.call && self.id.nil?
          self.assign_attributes(status: 'expired')
        elsif expires_on < Proc.new{Time.now}.call
          self.update_column(:status, 'expired')
        end
      end
    end
    self.read_attribute(:status)
  end

  def expiring_soon?
    unless self.status == 'expired'
      if self.expiry_year && self.expiry_month && self.is_default_card && self.user.current_subscription

        expiration = Date.new(self.expiry_year, self.expiry_month, 1)
        month_before_expiration = Date.new(self.expiry_year, self.expiry_month, 1) - 1.month

        if (Proc.new{Time.now}.call) > month_before_expiration && (Proc.new{Time.now}.call < expiration)
          true
        else
          false
        end

      end
    end
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

end
