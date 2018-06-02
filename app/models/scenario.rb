# == Schema Information
#
# Table name: scenarios
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  constructed_response_id  :integer
#  sorting_order            :integer
#  text_content             :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class Scenario < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :constructed_response_id, :sorting_order, :text_content

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :constructed_response
  has_many :scenario_questions
  has_many :scenario_answers


  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :constructed_response_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :text_content, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

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
