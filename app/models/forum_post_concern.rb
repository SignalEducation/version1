class ForumPostConcern < ActiveRecord::Base

  # attr-accessible
  attr_accessible :forum_post_id, :user_id, :reason, :live

  # Constants

  # relationships
  belongs_to :forum_post
  belongs_to :user

  # validation
  validates :forum_post_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :reason, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:forum_post_id) }

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
