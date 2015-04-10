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
  attr_accessible :course_module_element_id, :background_color, :foreground_color,
                  :flash_card_stacks_attributes

  # constants

  # relationships
  belongs_to :course_module_element
  has_many :flash_card_stacks
  accepts_nested_attributes_for :flash_card_stacks

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
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

  def spawn_flash_card_stack
    self.flash_card_stacks.build(content_type: 'Cards', sorting_order: 0)
  end

  def spawn_flash_card
    self.flash_card_stacks.last.flash_cards.build(sorting_order: 0)
    self.flash_card_stacks.last.flash_cards.last.quiz_contents.build(sorting_order: 0)
  end

  def spawn_flash_quiz
    self.flash_card_stacks.first.build_flash_quiz
    self.flash_card_stacks.first.flash_quiz.quiz_questions.build
    self.flash_card_stacks.first.flash_quiz.quiz_questions.last.quiz_contents.build(sorting_order: 0)
    2.times do |counter|
      self.flash_card_stacks.first.flash_quiz.quiz_questions.last.quiz_answers.build
      self.flash_card_stacks.first.flash_quiz.quiz_questions.last.quiz_answers.last.quiz_contents.build(sorting_order: counter)
    end
  end

  def spawn_missing_children
    spawn_flash_card_stack if self.flash_card_stacks.empty?
    spawn_flash_quiz if self.flash_card_stacks.first.try(:flash_quiz).nil?
    spawn_flash_card if self.flash_card_stacks.first.try(:flash_cards).empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, i18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
