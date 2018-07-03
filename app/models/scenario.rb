# == Schema Information
#
# Table name: scenarios
#
#  id                      :integer          not null, primary key
#  constructed_response_id :integer
#  sorting_order           :integer
#  text_content            :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  destroyed_at            :datetime
#

class Scenario < ActiveRecord::Base

  # attr-accessible
  attr_accessible :constructed_response_id, :sorting_order, :text_content,
                  :scenario_questions_attributes

  # Constants

  # relationships
  belongs_to :constructed_response
  has_many :scenario_questions

  accepts_nested_attributes_for :scenario_questions, allow_destroy: true, reject_if: lambda { |attributes| scenario_nested_question_is_blank?(attributes) }


  # validation
  validates :constructed_response_id, presence: true, on: :update,
            numericality: {only_integer: true, greater_than: 0}
  validates :text_content, presence: true, on: :update

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:constructed_response_id) }

  # class methods
  def self.scenario_nested_question_is_blank?(attributes)
    attributes['text_content'].blank?
  end


  # instance methods
  def destroyable?
    true
  end

  def add_an_empty_scenario_question
    self.scenario_questions.build
    self.scenario_questions.last.scenario_id = self.id
    2.times do |number|
      self.scenario_questions.last.scenario_answer_templates.build(
          sorting_order: number + 1,
          spreadsheet_editor_content: '[]',
          editor_type: (number.odd? ? 'text_editor' : 'spreadsheet_editor')
      )
    end

 end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
