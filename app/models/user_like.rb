# == Schema Information
#
# Table name: user_likes
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  likeable_type :string(255)
#  likeable_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class UserLike < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :likeable_type, :likeable_id

  # Constants

  # relationships
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :likeable_type, presence: true
  validates :likeable_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }

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
