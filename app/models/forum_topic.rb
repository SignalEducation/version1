# == Schema Information
#
# Table name: forum_topics
#
#  id                       :integer          not null, primary key
#  forum_topic_id           :integer
#  course_module_element_id :integer
#  heading                  :string(255)
#  description              :text
#  active                   :boolean          default(TRUE), not null
#  publish_from             :datetime
#  publish_until            :datetime
#  reviewed_by              :integer
#  created_at               :datetime
#  updated_at               :datetime
#

class ForumTopic < ActiveRecord::Base

  # attr-accessible
  attr_accessible :forum_topic_id, :course_module_element_id, :heading, :description, :active, :publish_from, :publish_until, :reviewed_by

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :parent, class_name: 'ForumTopic', foreign_key: :forum_topic_id
  belongs_to :forum_topic
  # todo belongs_to :reviewer, class_name: 'User', foreign_key: :reviewer_id
  has_many :forum_posts

  # validation
  validates :forum_topic_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :heading, presence: true
  validates :description, presence: true
  validates :publish_from, presence: true
  validates :publish_until, presence: true
  validates :reviewed_by, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:forum_topic_id) }

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
