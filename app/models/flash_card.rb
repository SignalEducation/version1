# == Schema Information
#
# Table name: flash_cards
#
#  id                  :integer          not null, primary key
#  flash_card_stack_id :integer
#  sorting_order       :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class FlashCard < ActiveRecord::Base

  # attr-accessible
  attr_accessible :flash_card_stack_id, :sorting_order, :quiz_contents_attributes

  # Constants

  # relationships
  belongs_to :flash_card_stack
  has_many :quiz_contents, -> { order(:sorting_order) }
  accepts_nested_attributes_for :quiz_contents

  # validation
  validates :flash_card_stack_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :sorting_order, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:flash_card_stack_id, :sorting_order) }

  # class methods

  # instance methods
  def destroyable?
    self.quiz_contents.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
