class UserNotification < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :subject_line, :content, :email_required, :email_sent_at, :unread, :destroyed_at, :message_type, :forum_topic_id, :forum_post_id, :tutor_id, :falling_behind, :blog_post_id

  # Constants

  # relationships
  belongs_to :user
  belongs_to :forum_topic
  belongs_to :forum_post
  belongs_to :tutor
  belongs_to :blog_post

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_line, presence: true
  validates :content, presence: true
  validates :email_sent_at, presence: true
  validates :destroyed_at, presence: true
  validates :message_type, presence: true
  validates :forum_topic_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :forum_post_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :tutor_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :blog_post_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
