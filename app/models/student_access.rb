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

  #TODO Add validation to ensure a SubscriptionID is present if trial_ended_date is present
  #TODO ensure some method to ensure once it has a value it can't return to nil

  # callbacks
  before_destroy :check_dependencies
  after_save :post_save_callbacks

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_trial, -> { where(account_type: 'Trial') }
  scope :all_sub, -> { where(account_type: 'Subscription') }
  scope :all_comp, -> { where(account_type: 'Complimentary') }

  # class methods

  # instance methods
  def destroyable?
    true
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

  def recalculate_access_from_limits
    if self.user.student_user?
      if self.user.trial_or_sub_user?
        if self.trial_access? && self.trial_started_date
          time_now = Proc.new{Time.now.to_datetime}.call
          new_trial_ending = self.trial_started_date + self.trial_days_limit.days
          if time_now >= new_trial_ending || self.content_seconds_consumed >= self.trial_seconds_limit
            self.update_columns(trial_ended_date: time_now, content_access: false)
          elsif time_now <= new_trial_ending || self.content_seconds_consumed <= self.trial_seconds_limit
            self.update_columns(trial_ended_date: nil, content_access: true, trial_ending_at_date: new_trial_ending)
          end
        elsif self.subscription_access? && self.subscription_id
          if self.subscription.active
            if %w(unpaid suspended canceled).include?(self.subscription.current_status)
              self.update_column(:content_access, false)
            elsif %w(active past_due canceled-pending).include?(self.subscription.current_status)
              self.update_column(:content_access, true)
            end
          end
        end
      elsif self.user.complimentary_user?
        self.update_columns(content_access: true, account_type: 'Complimentary')
      end
    else
      self.update_columns(content_access: true, account_type: 'Complimentary')
    end
  end

  def start_trial_access
    date_now = Proc.new{Time.now.to_datetime}.call
    self.trial_started_date = date_now
    self.trial_ending_at_date = self.trial_started_date + self.trial_days_limit.days
    self.account_type = 'Trial'
    self.content_access = true
    self.save
    TrialExpirationWorker.perform_at(self.trial_ending_at_date, self.user_id)
  end

  def check_trial_access
    date_now = Proc.new{Time.now.to_datetime}.call
    if date_now > self.trial_ending_at_date || self.content_seconds_consumed > self.trial_seconds_limit
      self.content_access = false
      self.trial_ended_date = date_now
      self.save
    else
      TrialExpirationWorker.perform_at(self.trial_ending_at_date, self.user_id)
    end
  end

  def update_subscription_access(sub_id)
    # Called from the subscription creation process or subscription update process (current_status change)
    subscription = Subscription.find(sub_id)
    self.subscription_id = sub_id
    self.account_type = 'Subscription'
    self.trial_ended_date = Proc.new{Time.now.to_datetime}.call unless self.trial_ended_date
    if %w(unpaid suspended canceled).include?(subscription.current_status)
      self.content_access = false
    elsif %w(active past_due canceled-pending).include?(subscription.current_status)
      self.content_access = true
    end
    self.save
  end

  def convert_to_comp_access

  end

  def convert_to_trial_access

  end

  protected

  def post_save_callbacks
    unless Rails.env.test?
      IntercomCreateUserWorker.perform_async(self.user_id)
      self.recalculate_access_from_limits
      if self.user.student_user? && self.trial_access? && self.trial_ending_at_date && !self.trial_ended_date
        TrialExpirationWorker.perform_at(self.trial_ending_at_date, self.user_id)  unless Rails.env.test?
      end
    end
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
