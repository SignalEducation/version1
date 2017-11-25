# == Schema Information
#
# Table name: student_accesses
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  trial_started_date       :datetime
#  trial_ending_at_date     :datetime
#  trial_ended_date         :datetime
#  trial_seconds_limit      :integer
#  trial_days_limit         :integer
#  content_seconds_consumed :integer          default(0)
#  subscription_id          :integer
#  account_type             :string
#  content_access           :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class StudentAccess < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :trial_started_date, :trial_ending_at_date,
                  :trial_ended_date, :trial_seconds_limit, :trial_days_limit,
                  :content_seconds_consumed, :subscription_id, :account_type,
                  :content_access

  # Constants
  ACCOUNT_TYPES = %w(Trial Subscription)

  # relationships
  belongs_to :user
  has_one :subscription

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :trial_seconds_limit, presence: true
  validates :trial_days_limit, presence: true
  validates :account_type, presence: true, inclusion: {in: ACCOUNT_TYPES}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_trial, -> { where(account_type: 'Trial') }
  scope :all_sub, -> { where(account_type: 'Subscription') }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  def subscription
    Subscription.where(id: self.subscription_id, active: true).last
  end

  def trial_access?
    self.account_type == 'Trial'
  end

  def subscription_access?
    self.account_type == 'Subscription'
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
