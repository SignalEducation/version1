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
  attr_accessible :user_id, :subscription_id, :account_type

  # Constants
  ACCOUNT_TYPES = %w(Trial Subscription Complimentary)

  # relationships
  belongs_to :user
  belongs_to :subscription

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :account_type, presence: true, inclusion: {in: ACCOUNT_TYPES}

  # When no subscription_id is present the user is on a trial access plan
  # Remove the content_access boolean, the subscription will determine access to each exam_body content

  # callbacks
  before_destroy :check_dependencies
  after_update :create_or_update_intercom_user

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

  def convert_to_trial_access
    self.update_attributes(account_type: 'Trial', subscription_id: nil)
  end

  def convert_to_subscription_access(subscription_id)
    self.update_attributes(subscription_id: subscription_id, account_type: 'Subscription')
  end

  def convert_to_complimentary_access
    self.update_attributes(account_type: 'Complimentary', subscription_id: nil)
  end

  def check_student_access
    if self.user.complimentary_user? || self.user.non_student_user?
      self.convert_to_complimentary_access
    elsif self.user.trial_or_sub_user?
      if self.subscription_id
        self.update_attributes(account_type: 'Subscription')
      else
        self.convert_to_trial_access
      end
    else
      self.convert_to_trial_access
    end
  end

  def permission_to_see_content(course_module_element=nil, subject_course_resource=nil, scul=nil)

    if course_module_element
      case account_type
      when 'Trial'
        course_module_element.available_for_trial(scul)
      when 'Subscription'
        self.subscription.valid_subscription? ? course_module_element.available_for_subscription(scul) : 'subscription-restriction'
      when 'Complimentary'
        course_module_element.available_for_complimentary(scul)
      else
        'account-issue'
      end

    else
      case account_type
      when 'Trial'
        subject_course_resource.available_on_trial ? 'valid' : 'trial-restriction'
      when 'Subscription'
        'valid'
      when 'Complimentary'
        'valid'
      else
        'account-issue'
      end

    end

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
