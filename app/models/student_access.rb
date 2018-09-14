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
  ACCOUNT_TYPES = %w(Trial Subscription Complimentary)

  # relationships
  belongs_to :user
  belongs_to :subscription

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :trial_seconds_limit, presence: true
  validates :trial_days_limit, presence: true
  validates :account_type, presence: true, inclusion: {in: ACCOUNT_TYPES}


  # callbacks
  before_destroy :check_dependencies
  after_save :create_or_update_intercom_user

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
    date_now = Proc.new{Time.now.to_datetime}.call
    self.trial_started_date = date_now
    self.trial_ending_at_date = self.trial_started_date + self.trial_days_limit.days
    self.account_type = 'Trial'
    self.content_access = true
    self.save
    TrialExpirationWorker.perform_at(self.trial_ending_at_date, self.user_id)
  end

  def check_trial_access_is_valid
    if self.user.student_user? && self.user.trial_access? &&  self.trial_started_date
      date_now = Proc.new{Time.now.to_datetime}.call
      if date_now > self.trial_ending_at_date || self.content_seconds_consumed > self.trial_seconds_limit
        self.content_access = false
        self.trial_ended_date = date_now
        self.save
      else
        # Need to reset the access boolean and trial_ended_date
        # As the users trial limits may have been changed after it expired
        self.trial_ended_date = nil
        self.content_access = true
        TrialExpirationWorker.perform_at(self.trial_ending_at_date, self.user_id)
      end
    end
  end

  def convert_to_subscription_access(subscription_id)
    # Called from the subscription after_save update_student_access
    subscription = Subscription.find(subscription_id)
    self.subscription_id = subscription_id
    self.account_type = 'Subscription'
    self.trial_ended_date = Proc.new{Time.now.to_datetime}.call unless self.trial_ended_date
    if %w(unpaid suspended canceled).include?(subscription.current_status)
      self.content_access = false
    elsif %w(active past_due canceled-pending).include?(subscription.current_status)
      self.content_access = true
    end
    self.save
  end

  def check_subscription_access_is_valid
    if self.subscription && self.user.subscription_user?
      if %w(unpaid suspended canceled).include?(self.subscription.current_status)
        self.content_access = false
      elsif %w(active past_due canceled-pending).include?(self.subscription.current_status)
        self.content_access = true
      end
      self.save
    end
  end

  def convert_to_complimentary_access
    if self.user.complimentary_user?
      date_now = Proc.new{Time.now.to_datetime}.call
      self.trial_ended_date = date_now unless self.trial_ended_date
      self.account_type = 'Complimentary'
      self.content_access = true
      self.save
    end
  end

  def check_student_access
    if self.user.trial_or_sub_user?
      if self.trial_access? && self.trial_started_date
        self.check_trial_access_is_valid
      elsif self.trial_access? && !self.trial_started_date && self.subscriptions.count == 0
        # If no trial_started_date and is trial_access then it is user just converted from comp access
        self.start_trial_access
      elsif self.subscription_access?  && self.subscriptions.count >= 1 && self.subscription_id
        self.check_subscription_access_is_valid
      end

    elsif self.user.non_student_user?
      self.convert_to_complimentary_access
    else
      self.start_trial_access
    end
  end

  protected

  def post_save_callbacks
    self.check_student_access
  end

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
