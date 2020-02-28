# == Schema Information
#
# Table name: constructed_response_attempts
#
#  id                                :integer          not null, primary key
#  constructed_response_id           :integer
#  scenario_id                       :integer
#  course_module_element_id          :integer
#  course_module_element_user_log_id :integer
#  user_id                           :integer
#  original_scenario_text_content    :text
#  user_edited_scenario_text_content :text
#  status                            :string
#  flagged_for_review                :boolean          default("false")
#  time_in_seconds                   :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  guid                              :string
#  scratch_pad_text                  :text
#

class ConstructedResponseAttempt < ApplicationRecord

  # Constants
  STATUS = %w(Incomplete Completed)

  # relationships
  belongs_to :constructed_response
  belongs_to :scenario
  belongs_to :course_module_element
  belongs_to :course_module_element_user_log
  belongs_to :user
  has_many :scenario_question_attempts

  accepts_nested_attributes_for :scenario_question_attempts

  # validation
  validates :constructed_response_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :scenario_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_user_log_id, presence: true,
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
