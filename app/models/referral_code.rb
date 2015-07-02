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

class ReferralCode < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id

  # Constants

  # relationships
  belongs_to :user
  has_many :referred_signups

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0},
            uniqueness: true
  validates :code, presence: true,
            uniqueness: true

  # callbacks
  before_destroy :check_dependencies
  before_validation :create_code, on: :create

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    referred_signups.empty?
  end

  def payed_referred_signups
    referred_signups.where("payed_at is not null")
  end

  def unpayed_referred_signups
    referred_signups.where(payed_at: nil)
  end

  def referred_signups_ready_for_paying
    unpayed_referred_signups.where("maturing_on <= ?", Time.now.utc.end_of_day)
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
    return false unless usr.individual_student? || usr.corporate_student? || usr.tutor? || usr.blogger?

    if usr
      new_code = Digest::SHA1.hexdigest("#{usr.id}#{usr.email}")[0..6]
      while ReferralCode.where(code: new_code).count > 0
        new_code = Digest::SHA1.hexdigest("#{usr.id}#{usr.email}#{Time.now.to_i}")[0..6]
      end
      self.code = new_code
    end
  end
end
