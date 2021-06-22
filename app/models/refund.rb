# frozen_string_literal: true

# == Schema Information
#
# Table name: refunds
#
#  id                 :integer          not null, primary key
#  stripe_guid        :string
#  charge_id          :integer
#  stripe_charge_guid :string
#  invoice_id         :integer
#  subscription_id    :integer
#  user_id            :integer
#  manager_id         :integer
#  amount             :integer
#  reason             :text
#  status             :string
#  livemode           :boolean          default("true")
#  stripe_refund_data :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Refund < ApplicationRecord
  include RefundReport

  # Constants
  REASONS = %w[duplicate fraudulent requested_by_customer].freeze

  # relationships
  belongs_to :charge
  belongs_to :invoice
  belongs_to :subscription
  belongs_to :user
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id, inverse_of: :refunds

  # validation
  validates :stripe_guid, uniqueness: true
  validates :amount, presence: true
  validates :reason, presence: true, inclusion: { in: REASONS }
  validates :charge_id, :invoice_id,
            :subscription_id, :user_id, :manager_id,
            presence: true, numericality: { only_integer: true, greater_than: 0 }

  # callbacks
  before_destroy :check_dependencies
  after_create :create_on_stripe
  after_save :update_total_revenue

  # scopes
  scope :all_in_order, -> { order(:stripe_guid) }

  def self.to_csv(options = {})
    attributes = %w[inv_id invoice_created sub_id sub_created user_email user_created
                    payment_provider sub_stripe_guid sub_paypal_guid sub_exam_body sub_status
                    sub_type invoice_type payment_interval plan_name currency_symbol plan_price
                    sub_total total card_country user_country hubspot_source hubspot_source_1
                    hubspot_source_2 first_visit_source first_visit_utm_campaign first_visit_medium
                    first_visit_date first_visit_referring_domain first_visit_landing_page
                    first_visit_referrer refund_id refunded_on refund_status stripe_id refund_amount
                    inv_total inv_created invoice_type sub_status sub_type first_visit
                    first_visit_search_keyword first_visit_country user_subscriptions_revenue
                    user_orders_revenue user_total_revenue]

    CSV.generate(options) do |csv|
      csv << attributes
      all.find_each do |refund|
        csv << attributes.map { |attr| refund.send(attr) }
      end
    end
  end

  # instance methods
  def destroyable?
    false
  end

  def update_total_revenue
    return if subscription_id.nil?

    subscription.update_revenue(:decrement!, amount)
  end

  protected

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end

  def create_on_stripe
    stripe_refund = Stripe::Refund.create(charge: stripe_charge_guid,
                                          amount: amount, reason: reason)
    update(stripe_guid: stripe_refund[:id],
           status: stripe_refund[:status],
           livemode: stripe_refund[:livemode],
           stripe_refund_data: stripe_refund.to_hash.deep_dup)
  rescue Stripe::InvalidRequestError => e
    raise Learnsignal::PaymentError, e.message
  end
end
