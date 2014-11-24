class RawVideoFile < ActiveRecord::Base

  # attr-accessible
  attr_accessible :file_name, :course_module_element_video_id, :transcode_requested

  # Constants

  # relationships
  belongs_to :course_module_element_video

  # validation
  validates :file_name, presence: true
  validates :course_module_element_video_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:file_name) }

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
