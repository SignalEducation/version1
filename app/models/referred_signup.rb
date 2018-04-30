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
  attr_accessible :referral_code_id, :user_id, :referrer_url, :payed_at, :subscription_id

  # Constants

  # relationships
  belongs_to :referral_code
  belongs_to :user
  belongs_to :subscription

  # validation
  validates :referral_code_id, presence: true,
            uniqueness: { scope: :user_id, message: I18n.t('models.referred_signups.user_can_be_referred_only_once') }
  validates :user_id, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:referral_code_id) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :last_month, -> { where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  scope :all_payed, -> { where.not(payed_at: nil) }


  # class methods
  def self.to_csv(options = {})
    #attributes are either model attributes or data generate in methods below
    attributes = %w{referral_email created_at subscription_id referrer_url}
    CSV.generate(options) do |csv|
      csv << attributes
      all.each do |course|
        csv << attributes.map{ |attr| course.send(attr) }
      end
    end
  end

  # instance methods
  def destroyable?
    true
  end

  def referrer_user
    self.referral_code.user
  end

  def subscription_referral
    self.subscription_id
  end

  def referral_email
    self.user.email
  end


  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
