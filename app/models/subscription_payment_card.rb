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
                  :dynamic_last4, :customer_guid, :is_default_card,
                  :stripe_token, :make_default_card

  # Constants
  STATUSES = %w(card-live not-live expired)
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
  before_validation :create_on_stripe_using_token, on: :create, if: :stripe_token
  after_create :update_as_the_default_card, if: :is_default_card

  # scopes
  scope :all_in_order, -> { order(:user_id, :status) }
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
    if this_customers_cards.length > 1
      this_customers_cards.update_all(is_default_card: false, status: 'not-live')
      the_default_card.update_attributes(is_default_card: true, status: 'card-live')
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

  def create_on_stripe_using_token
    if self.stripe_token.to_s.length > 0 && self.user.try(:stripe_customer_id) && self.stripe_card_guid.blank?
      stripe_customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
      new_card_hash = Rails.env.test? ?
              stripe_customer.cards.create({card: self.stripe_token}).to_hash :
              stripe_customer.sources.create({source: self.stripe_token}).to_hash
      if new_card_hash
        self.stripe_card_guid = new_card_hash[:id]
        self.status = (new_card_hash[:cvc_check] == 'pass' && self.make_default_card) ? 'card-live' : 'not-live'
        self.brand = new_card_hash[:brand]
        self.last_4 = new_card_hash[:last4]
        self.expiry_month = new_card_hash[:exp_month]
        self.expiry_year = new_card_hash[:exp_year]
        self.billing_address = new_card_hash[:address_line_1]
        self.billing_country = new_card_hash[:country]
        self.billing_country_id = Country.find_by_iso_code(new_card_hash[:country].upcase)
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
      end
    end

  rescue => e
    Rails.logger.error "ERROR: SubscriptionPaymentCard#create_on_stripe_using_token - error: #{e.inspect}.  Self: #{self.inspect}."
    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    false
  end

  def destroyable?
    self.subscription_transactions.empty?
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
      # tell Stripe this is the live card.
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

end
