class ForumTopic < ActiveRecord::Base

  # attr-accessible
  attr_accessible :forum_topic_id, :course_module_element_id, :heading, :description, :active, :publish_from, :publish_until, :reviewed_by

  # Constants

  # relationships
  belongs_to :forum_topic
  belongs_to :course_module_element

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
