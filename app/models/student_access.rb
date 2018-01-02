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
  belongs_to :subscription

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :trial_seconds_limit, presence: true
  validates :trial_days_limit, presence: true
  validates :account_type, presence: true, inclusion: {in: ACCOUNT_TYPES}

  # callbacks
  before_destroy :check_dependencies
  after_save :create_on_intercom, :create_trial_expiration_worker

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_trial, -> { where(account_type: 'Trial') }
  scope :all_sub, -> { where(account_type: 'Subscription') }

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

  def recalculate_access_from_limits
    if self.trial_access? && self.trial_started_date
      time_now = Proc.new{Time.now.to_datetime}.call
      new_trial_ending = self.trial_started_date + self.trial_days_limit.days

      if time_now >= new_trial_ending || self.content_seconds_consumed >= self.trial_seconds_limit
        self.update_columns(trial_ended_date: time_now, content_access: false)

      elsif time_now <= new_trial_ending || self.content_seconds_consumed <= self.trial_seconds_limit
        self.update_columns(trial_ended_date: nil, content_access: true, trial_ending_at_date: new_trial_ending)
      end

    end
  end

  protected

  def create_on_intercom
    IntercomCreateUserWorker.perform_async(self.user_id) unless Rails.env.test?
  end

  def create_trial_expiration_worker
    if self.user.student_user? && self.user.trial_user? && self.trial_ending_at_date && !self.trial_ended_date
      TrialExpirationWorker.perform_at(self.trial_ending_at_date, self.user_id)  unless Rails.env.test?
    end
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
