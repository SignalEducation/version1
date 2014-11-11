# == Schema Information
#
# Table name: quiz_contents
#
#  id               :integer          not null, primary key
#  quiz_question_id :integer
#  quiz_answer_id   :integer
#  text_content     :text
#  contains_mathjax :boolean          not null
#  contains_image   :boolean          not null
#  sorting_order    :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class QuizContent < ActiveRecord::Base

  # attr-accessible
  attr_accessible :quiz_question_id, :quiz_answer_id, :text_content, :contains_mathjax, :contains_image, :sorting_order

  # Constants

  # relationships
  belongs_to :quiz_answer
  belongs_to :quiz_question

  # validation
  validate  :question_or_answer_only
  validates :quiz_question_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_answer_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :text_content, presence: true
  validates :sorting_order, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :quiz_question_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def question_or_answer_only
    if self.quiz_question_id && self.quiz_answer_id
      errors.add(:base, I18n.t('models.quiz_content.can_t_assign_to_question_and_answer'))
    elsif self.quiz_question_id.nil? && self.quiz_answer_id.nil?
      errors.add(:base, I18n.t('models.quiz_content.must_assign_to_question_or_answer'))
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
