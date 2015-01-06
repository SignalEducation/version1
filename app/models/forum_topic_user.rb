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

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :forum_topic_id

  # Constants

  # relationships
  belongs_to :user
  belongs_to :forum_topic

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :forum_topic_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

end
