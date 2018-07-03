# == Schema Information
#
# Table name: scenario_answer_templates
#
#  id                   :integer          not null, primary key
#  scenario_question_id :integer
#  sorting_order        :integer
#  editor_type          :string
#  text_content         :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  destroyed_at         :datetime
#

class ScenarioAnswerTemplate < ActiveRecord::Base

  #TODO Is this needed???
  serialize :text_content, JSON

  # attr-accessible
  attr_accessible :scenario_question_id, :sorting_order, :editor_type, :text_content

  # Constants
  FORMAT_TYPES = %w(text_editor spreadsheet_editor)


  # relationships
  belongs_to :scenario_question
  has_many :scenario_answer_attempts

  # validation
  validates :scenario_question_id, presence: true, on: :update,
            numericality: {only_integer: true, greater_than: 0}
  validates :editor_type, presence: true, inclusion: {in: FORMAT_TYPES},
            length: {maximum: 255}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :scenario_question_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def spreadsheet_editor?
    editor_type == 'spreadsheet_editor'
  end

  def text_editor?
    editor_type == 'text_editor'
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
