# == Schema Information
#
# Table name: course_module_element_flash_card_packs
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  background_color         :string
#  foreground_color         :string
#  created_at               :datetime
#  updated_at               :datetime
#  destroyed_at             :datetime
#

class CourseModuleElementFlashCardPack < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :course_module_element_id, :background_color, :foreground_color,
                  :flash_card_stacks_attributes

  # constants

  # relationships
  belongs_to :course_module_element
  has_many :flash_card_stacks, -> { order(:sorting_order) }, inverse_of: :course_module_element_flash_card_pack
  accepts_nested_attributes_for :flash_card_stacks, allow_destroy: true

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :background_color, presence: true, length: {maximum: 255}
  validates :foreground_color, presence: true, length: {maximum: 255}

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id).where(destroyed_at: nil) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list += self.flash_card_stacks.to_a
    the_list
  end

  def spawn_flash_quiz
  end

  protected

end
