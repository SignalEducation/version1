# == Schema Information
#
# Table name: referred_signups
#
#  id               :integer          not null, primary key
#  referral_code_id :integer
#  user_id          :integer
#  referrer_url     :string(2048)
#  subscription_id  :integer
#  maturing_on      :datetime
#  payed_at         :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ReferredSignup < ActiveRecord::Base

  # attr-accessible
  attr_accessible :referral_code_id, :user_id, :referrer_url, :subscription_id, :maturing_on, :payed_at

  # Constants

  # relationships
  belongs_to :referral_code
  belongs_to :user
  belongs_to :subscription

  # validation
  validates :referral_code_id, presence: true,
            uniqueness: { scope: :user_id, message: I18n.t('models.referred_signups.user_can_be_referred_only_once') }
  validates :user_id, presence: true
  validates :subscription_id, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:referral_code_id) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :last_month, -> { where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
