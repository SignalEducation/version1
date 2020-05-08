# frozen_string_literal: true

class ConstructedResponseAttempt < ApplicationRecord
  # Constants
  STATUS = %w[Incomplete Completed]

  # relationships
  belongs_to :constructed_response
  belongs_to :scenario
  belongs_to :course_step
  belongs_to :course_step_log
  belongs_to :user
  has_many :scenario_question_attempts

  accepts_nested_attributes_for :scenario_question_attempts

  # validation
  validates :constructed_response_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :scenario_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_step_log_id, presence: true,
            on: :update, numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :original_scenario_text_content, presence: true
  validates :status, inclusion: {in: STATUS}, length: {maximum: 255}
  validates :guid, presence: true, uniqueness: true, length: {maximum: 255}
  validates :user_edited_scenario_text_content, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:constructed_response_id) }

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
