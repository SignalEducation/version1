# == Schema Information
#
# Table name: scenario_question_attempts
#
#  id                                 :integer          not null, primary key
#  constructed_response_attempt_id    :integer
#  user_id                            :integer
#  scenario_question_id               :integer
#  status                             :string
#  flagged_for_review                 :boolean          default(FALSE)
#  original_scenario_question_text    :text
#  user_edited_scenario_question_text :text
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  sorting_order                      :integer
#

class ScenarioQuestionAttempt < ActiveRecord::Base

  # attr-accessible
  attr_accessible :constructed_response_attempt_id, :user_id, :scenario_question_id,
                  :status, :flagged_for_review, :original_scenario_question_text,
                  :user_edited_scenario_question_text,
                  :scenario_answer_attempts_attributes, :sorting_order

  # Constants
  STATUS = %w(Unseen Seen)

  # relationships
  belongs_to :scenario_question
  belongs_to :user
  belongs_to :constructed_response_attempt
  has_many :scenario_answer_attempts

  accepts_nested_attributes_for :scenario_answer_attempts

  # validation
  validates :constructed_response_attempt_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :scenario_question_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :status, presence: true, inclusion: {in: STATUS}
  validates :original_scenario_question_text, presence: true
  validates :user_edited_scenario_question_text, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :constructed_response_attempt_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
