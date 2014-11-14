# == Schema Information
#
# Table name: user_notifications
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  subject_line   :string(255)
#  content        :text
#  email_required :boolean          default(FALSE), not null
#  email_sent_at  :datetime
#  unread         :boolean          default(TRUE), not null
#  destroyed_at   :datetime
#  message_type   :string(255)
#  forum_topic_id :integer
#  forum_post_id  :integer
#  tutor_id       :integer
#  falling_behind :boolean          not null
#  blog_post_id   :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class UserNotification < ActiveRecord::Base

  include Archivable

  # attr-accessible
  attr_accessible :user_id, :subject_line, :content, :email_required, :email_sent_at,
                  :unread, :destroyed_at, :message_type, :forum_topic_id,
                  :forum_post_id, :tutor_id, :falling_behind, :blog_post_id

  # Constants
  MESSAGE_TYPES = %w(blog forum marketing study_plan)

  # relationships
  belongs_to :user
  # todo belongs_to :forum_topic
  # todo belongs_to :forum_post
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id
  # todo belongs_to :blog_post

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_line, presence: true
  validates :content, presence: true
  validates :message_type, inclusion: {in: MESSAGE_TYPES}
  validates :forum_topic_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :forum_post_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :tutor_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :blog_post_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  after_create :send_email_if_needed
  before_destroy :check_dependencies
  # before_destroy :destroy

  # scopes
  scope :all_in_order, -> { order(:user_id, :unread, :created_at) }
  scope :unread,  -> { where(unread: true) }
  scope :read,    -> { where(unread: false) }
  scope :deleted, -> { unscoped.where('destroyed_at IS NOT NULL') }
  scope :visible, -> { where(destroyed_at: nil) }
  default_scope{visible.all_in_order}

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def send_email_if_needed
   # UserMailer.send_notification(self.id).delayed_job if self.email_required
  end

  def mark_as_read
    self.unread = false
    self.save
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
