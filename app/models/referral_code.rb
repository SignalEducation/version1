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


  # instance methods
  def destroyable?
    referred_signups.empty?
  end

  def trial_referred_signups
    referred_signups.where(subscription_id: nil)
  end

  def subscription_referred_signups
    referred_signups.where.not(subscription_id: nil)
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
    return false unless usr.student_user?

    if usr
      new_code = Digest::SHA1.hexdigest("#{usr.id}#{usr.email}")[0..6]
      while ReferralCode.where(code: new_code).count > 0
        new_code = Digest::SHA1.hexdigest("#{usr.id}#{usr.email}#{Time.now.to_i}")[0..6]
      end
      self.code = new_code
    end
  end
end
