# == Schema Information
#
# Table name: forum_topic_users
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  forum_topic_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class ForumTopicUser < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :forum_topic_id

  # Constants

  # relationships
  belongs_to :user
  # todo belongs_to :forum_topic

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :forum_topic_id, presence: true,
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
