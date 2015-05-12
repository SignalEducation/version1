# == Schema Information
#
# Table name: flash_cards
#
#  id                  :integer          not null, primary key
#  flash_card_stack_id :integer
#  sorting_order       :integer
#  created_at          :datetime
#  updated_at          :datetime
#  destroyed_at        :datetime
#

class FlashCard < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :flash_card_stack_id, :sorting_order, :quiz_contents_attributes

  # Constants

  # relationships
  belongs_to :flash_card_stack, inverse_of: :flash_cards
  has_many :quiz_contents, -> { order(:sorting_order) }
  accepts_nested_attributes_for :quiz_contents, allow_destroy: true

  # validation
  validates :flash_card_stack_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :sorting_order, presence: true

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:flash_card_stack_id, :sorting_order).where(destroyed_at: nil) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list += self.quiz_contents.to_a
    the_list
  end

  protected

end
