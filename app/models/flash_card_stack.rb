# == Schema Information
#
# Table name: flash_card_stacks
#
#  id                                       :integer          not null, primary key
#  course_module_element_flash_card_pack_id :integer
#  name                                     :string(255)
#  sorting_order                            :integer
#  final_button_label                       :string(255)
#  content_type                             :string(255)
#  created_at                               :datetime
#  updated_at                               :datetime
#

class FlashCardStack < ActiveRecord::Base

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
  validates :name, presence: true
  validates :sorting_order, presence: true
  validates :final_button_label, presence: true
  validates :content_type, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_flash_card_pack_id, :sorting_order) }

  # class methods

  # instance methods
  def destroyable?
    true # children are killed automatically via the nested attributes declaration above.
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
