# == Schema Information
#
# Table name: referral_codes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  code       :string(7)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReferralCode < ApplicationRecord

  # Constants

  # relationships
  belongs_to :user
  has_many :referred_signups

  # validation
  validates :user_id, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  # callbacks
  before_destroy :check_dependencies
  before_validation :create_code, on: :create

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :with_children, -> { joins(:referred_signups).uniq.all }
  scope :by_user_email, lambda { |search| joins(:user).where('users.email = ?', search) }

  # class methods

  def self.search(search)
    if search
      ReferralCode.joins(:user).where('code ILIKE ? OR users.email ILIKE ? ', "%#{search}%", "%#{search}%")
    else
      ReferralCode.paginate(per_page: 50, page: params[:page]).with_children.all_in_order
    end
  end

  ## Structures data in CSV format for Excel downloads ##
  def self.to_csv(options = {})
    #attributes are either model attributes or data generate in methods below
    attributes = %w{code referrer_email referrer_country trial_referrals subscription_referrals total_referrals referrals_this_month referrals_last_month total_referrals}
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

  def trial_referred_signups
    referred_signups.where(subscription_id: nil)
  end

  def subscription_referred_signups
    referred_signups.where.not(subscription_id: nil)
  end


  def referrals_this_month
    referred_signups.this_month.count
  end

  def referrals_last_month
    referred_signups.last_month.count
  end

  def total_referrals
    referred_signups.count
  end

  def trial_referrals
    referred_signups.where(subscription_id: nil).count
  end

  def subscription_referrals
    referred_signups.where.not(subscription_id: nil).count
  end

  def referrer_email
    self.user.email
  end

  def referrer_country
    self.user.try(:country).try(:name)
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  # We have to ensure that referral code is unique per user. For SAH1
  # hash it is enough, in most cases, to take first 7 characters of
  # calculated hash.  In order to ensure uniqueness we are
  # concatenating user specific data for which we are calculating hash
  # (user's ID and mail). If this turns not to be enough we are adding
  # current time in epoch till unique code is created.
  def create_code
    return unless self.code.blank?

    usr = User.find(self.user_id)
    return false if usr.nil?

    if usr
      new_code = Digest::SHA1.hexdigest("#{usr.id}#{usr.email}")[0..6]
      while ReferralCode.where(code: new_code).count > 0
        new_code = Digest::SHA1.hexdigest("#{usr.id}#{usr.email}#{Time.now.to_i}")[0..6]
      end
      self.code = new_code
    end
  end
end
