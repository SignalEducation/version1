# == Schema Information
#
# Table name: flash_card_stacks
#
#  id                                       :integer          not null, primary key
#  course_module_element_flash_card_pack_id :integer
#  name                                     :string
#  sorting_order                            :integer
#  final_button_label                       :string
#  content_type                             :string
#  created_at                               :datetime
#  updated_at                               :datetime
#  destroyed_at                             :datetime
#

class FlashCardStack < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :course_module_element_flash_card_pack_id, :name, :sorting_order, :final_button_label, :content_type, :flash_cards_attributes, :flash_quiz_attributes

  # Constants
  CONTENT_TYPES = %w(Quiz Cards)

  # relationships
  belongs_to :course_module_element_flash_card_pack, inverse_of: :flash_card_stacks
  has_one :flash_quiz, inverse_of: :flash_card_stack
  has_many :flash_cards, -> { order(:sorting_order) }, inverse_of: :flash_card_stack
  accepts_nested_attributes_for :flash_cards, allow_destroy: true
  accepts_nested_attributes_for :flash_quiz, allow_destroy: true

  # validation
  validates :course_module_element_flash_card_pack_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :name, presence: true, length: {maximum: 255}
  validates :sorting_order, presence: true
  validates :final_button_label, presence: true, length: {maximum: 255}
  validates :content_type, presence: true, length: {maximum: 255}

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:course_module_element_flash_card_pack_id, :sorting_order).where(destroyed_at: nil) }

  # class methods

  # instance methods
  def destroyable?
    true # children are killed automatically via the nested attributes declaration above.
  end

  def destroyable_children
    the_list = []
    the_list << self.flash_quiz if self.flash_quiz
    the_list += self.flash_cards.to_a
    the_list
  end

  protected

end
