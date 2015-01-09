# == Schema Information
#
# Table name: forum_posts
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  content                   :text
#  forum_topic_id            :integer
#  blocked                   :boolean          default(FALSE), not null
#  response_to_forum_post_id :integer
#  created_at                :datetime
#  updated_at                :datetime
#

class ForumPost < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :content, :forum_topic_id, :blocked, :response_to_forum_post_id

  # Constants

  # relationships
  belongs_to :user
  belongs_to :forum_topic
  belongs_to :response_to_forum_post, class_name: 'ForumPost', foreign_key: :response_to_forum_post_id
  has_many :response_posts, class_name: 'ForumPost', foreign_key: :response_to_forum_post_id
  has_many :forum_post_concerns
  has_many :user_likes, as: :likeable
  has_many :user_notifications

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :content, presence: true
  validates :forum_topic_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :response_to_forum_post_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:forum_topic_id) }

  # class methods
  before_validation { squish_fields(:content) }

  # instance methods
  def destroyable?
    self.response_posts.empty? && self.forum_post_concerns.empty? && self.user_likes.empty? && self.user_notifications.empty?
  end

  def background_colour
    if self.user.admin?
       '#ffeebb'
    elsif self.user.tutor?
      '#eeffcc'
    elsif self.user.frequent_forum_user?
      '#eeeeff'
    else
      'inherit'
    end
  end

  protected

end
