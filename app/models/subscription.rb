# == Schema Information
#
# Table name: subscriptions
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  corporate_customer_id :integer
#  subscription_plan_id  :integer
#  stripe_guid           :string(255)
#  next_renewal_date     :date
#  complementary         :boolean          default(FALSE), not null
#  current_status        :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

class Subscription < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :corporate_customer_id, :subscription_plan_id,
                  :next_renewal_date, :complementary, :current_status,
                  :stripe_customer_id, :original_stripe_customer_data

  # Constants
  STATUSES = %w(trial active suspended paused cancelled)

  # relationships
  belongs_to :user
  belongs_to :corporate_customer
  has_many :invoices
  belongs_to :subscription_plan
  has_many :subscription_transactions

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :corporate_customer_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subscription_plan_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :next_renewal_date, presence: true
  validates :current_status, inclusion: {in: STATUSES}

  # callbacks
  before_create :create_on_stripe_platform
  before_update :update_on_stripe_platform

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_of_status, lambda { |the_status| where(current_status: the_status) }

  # class methods

  # instance methods
  def destroyable?
    self.invoices.empty?
  end

  protected

  def create_on_stripe_platform
    # todo stripe integration
    self.stripe_guid = 'sub_DUMMY_ABC123'
  end

  def update_on_stripe_platform
    # todo stripe integration
    self.stripe_guid = self.stripe_guid.split('-')[0] + '-' + ((self.stripe_guid.split('-')[1].to_i + 1).to_s)
  end

end
