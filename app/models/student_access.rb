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

  # Constants
  ACCOUNT_TYPES = %w(Trial Subscription Complimentary)

  # relationships
  belongs_to :user
  belongs_to :subscription, optional: true

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :trial_seconds_limit, presence: true
  validates :trial_days_limit, presence: true
  validates :account_type, presence: true, inclusion: {in: ACCOUNT_TYPES}
  # TODO - Add validation to ensure once a subscription_id is present it can't return to nil


  # callbacks
  before_destroy :check_dependencies
  after_save :create_or_update_intercom_user
  after_update :check_student_access

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_trial, -> { where(account_type: 'Trial') }
  scope :all_sub, -> { where(account_type: 'Subscription') }
  scope :all_comp, -> { where(account_type: 'Complimentary') }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  def trial_access?
    self.account_type == 'Trial'
  end

  def subscription_access?
    self.account_type == 'Subscription'
  end

  def complimentary_access?
    self.account_type == 'Complimentary'
  end

  def start_trial_access
    # Called from User get_and_verify method after verification email clicked
    # Or from the User when user_group has been changed to a complimentary one
    if self.trial_access?
      date_now = Proc.new{Time.now.to_datetime}.call
      self.update_columns(trial_started_date: date_now,
                             trial_ending_at_date: date_now + self.trial_days_limit.days,
                             account_type: 'Trial',
                             content_access: true)
      TrialExpirationWorker.perform_at(self.trial_ending_at_date, self.user_id)
      self.create_or_update_intercom_user
    else
      #For comp users being set to trial users
      date_now = Proc.new{Time.now.to_datetime}.call

      self.update_columns(trial_started_date: self.trial_started_date ? self.trial_started_date : date_now,
                          trial_ending_at_date: self.trial_ending_at_date ? self.trial_ending_at_date : date_now,
                          trial_ended_date: self.trial_ended_date ? self.trial_ended_date : date_now,
                          account_type: 'Trial',
                          content_access: false)
    end
  end

  def check_trial_access_is_valid

    if self.user.student_user? && self.trial_access? && self.trial_started_date
      date_now = Proc.new{Time.now.to_datetime}.call
      if date_now > (self.trial_started_date + self.trial_days_limit.days) || self.content_seconds_consumed > self.trial_seconds_limit
        self.update_columns(content_access: false, trial_ended_date: date_now)
      else
        # Need to reset the access boolean and trial_ended_date
        # As the users trial limits may have been changed after it expired
        self.update_columns(content_access: true,
                            trial_ending_at_date: self.trial_started_date + self.trial_days_limit.days,
                            trial_ended_date: nil)
        TrialExpirationWorker.perform_at(self.trial_ending_at_date, self.user_id) unless Rails.env.test?
      end
    end
    self.create_or_update_intercom_user
  end

  def convert_to_subscription_access(subscription_id)
    # Called from the subscription after_save update_student_access
    subscription = Subscription.find(subscription_id)
    trial_ended_date = self.trial_ended_date ? self.trial_ended_date : Proc.new{Time.now.to_datetime}.call
    if subscription.cancelled?
      access = false
    elsif subscription.active? || subscription.errored?
      access = true
    end
    self.update_columns(subscription_id: subscription_id, account_type: 'Subscription',
                        trial_ended_date: trial_ended_date, content_access: access)
    self.create_or_update_intercom_user
  end

  def check_subscription_access_is_valid
    if self.subscription && self.user.subscription_user?
      if subscription.cancelled?
        self.update_column(:content_access, false)
      elsif subscription.active? || subscription.errored?
        self.update_column(:content_access, true)
      end
    end
    self.create_or_update_intercom_user
  end

  def convert_to_complimentary_access
    if self.user.complimentary_user?
      date_now = self.trial_ended_date ? self.trial_ended_date : Proc.new{Time.now.to_datetime}.call
      self.update_columns(trial_ended_date: date_now,
                          account_type: 'Complimentary',
                          content_access: true)
    end
    self.create_or_update_intercom_user
  end

  def check_student_access
    if self.user.complimentary_user? || self.user.non_student_user?
      self.convert_to_complimentary_access
    elsif self.user.trial_or_sub_user?
      if self.trial_access? && self.trial_started_date
        self.check_trial_access_is_valid
      elsif self.trial_access? && !self.trial_started_date && self.user.subscriptions && self.user.subscriptions.count == 0
        # If no trial_started_date and is trial_access then it is user just converted from comp access
        self.start_trial_access
      elsif self.subscription_access?  && self.user.subscriptions.count >= 1 && self.subscription_id
        self.check_subscription_access_is_valid
      elsif self.complimentary_access?
        self.start_trial_access
      end
    else
      self.start_trial_access
    end
    self.create_or_update_intercom_user
  end

  protected

  def create_or_update_intercom_user
    IntercomCreateUserWorker.perform_async(self.user_id) unless Rails.env.test?
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
