# == Schema Information
#
# Table name: course_module_element_flash_card_packs
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  background_color         :string(255)
#  foreground_color         :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#

class CourseModuleElementFlashCardPack < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :background_color, :foreground_color

  # constants

  # relationships
  belongs_to :course_module_element
  has_many :flash_card_stacks

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :background_color, presence: true
  validates :foreground_color, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

  # class methods

  # instance methods
  def destroyable?
    self.flash_card_stacks.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, i18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
