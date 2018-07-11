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
    question_order = self.scenario_questions.any? ? self.scenario_questions.all_in_order.last.sorting_order + 1 : 1

    json = {"activeSheet":"Sheet1","sheets":[{"name":"Sheet1","rows":[],"columns":[],"selection":"A1:A1","activeCell":"A1:A1","frozenRows":0,"frozenColumns":0,"showGridLines":true,"gridLinesColor":nil,"mergedCells":[],"hyperlinks":[],"defaultCellStyle":{"fontFamily":"Arial","fontSize":"12"}}],"names":[],"columnWidth":64,"rowHeight":20}.to_json

    self.scenario_questions.build(sorting_order: question_order)
    self.scenario_questions.last.scenario_id = self.id
    2.times do |number|
      self.scenario_questions.last.scenario_answer_templates.build(
          sorting_order: number + 1,
          spreadsheet_editor_content: json,
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
