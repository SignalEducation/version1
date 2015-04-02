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
  attr_accessible :course_module_element_flash_card_pack_id, :name, :sorting_order, :final_button_label, :content_type

  # Constants
  CONTENT_TYPES = %w(Quiz Cards)

  # relationships
  belongs_to :course_module_element_flash_card_pack
  has_many :flash_quizzes
  has_many :flash_cards

  # validation
  validates :course_module_element_flash_card_pack_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :sorting_order, presence: true
  validates :final_button_label, presence: true
  validates :content_type, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_module_element_flash_card_pack_id) }

  # class methods

  # instance methods
  def destroyable?
    self.flash_cards.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
