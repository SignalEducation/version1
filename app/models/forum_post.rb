class ForumPost < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :content, :forum_topic_id, :blocked, :response_to_forum_post_id

  # Constants

  # relationships
  belongs_to :user
  belongs_to :forum_topic
  belongs_to :response_to_forum_post

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :content, presence: true
  validates :forum_topic_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :response_to_forum_post_id, presence: true,
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
