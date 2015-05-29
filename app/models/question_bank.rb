# == Schema Information
#
# Table name: question_banks
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  exam_level_id       :integer
#  number_of_questions :integer
#  easy_questions      :boolean          default(FALSE), not null
#  medium_questions    :boolean          default(FALSE), not null
#  hard_questions      :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class QuestionBank < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :exam_level_id, :number_of_questions, :easy_questions, :medium_questions, :hard_questions

  # Constants

  # relationships
  belongs_to :user
  belongs_to :exam_level

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :number_of_questions, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
