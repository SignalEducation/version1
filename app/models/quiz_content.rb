# == Schema Information
#
# Table name: quiz_contents
#
#  id               :integer          not null, primary key
#  quiz_question_id :integer
#  quiz_answer_id   :integer
#  text_content     :text
#  contains_mathjax :boolean          default(FALSE), not null
#  contains_image   :boolean          default(FALSE), not null
#  sorting_order    :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class QuizContent < ActiveRecord::Base

  # attr-accessible
  attr_accessible :quiz_question_id, :quiz_answer_id, :text_content, :sorting_order,
                  :content_type

  # Constants
  CONTENT_TYPES = %w(text image mathjax)

  # relationships
  belongs_to :quiz_answer
  belongs_to :quiz_question

  # validation
  validate  :question_or_answer_only, on: :update
  validates :quiz_question_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_answer_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :text_content, presence: true
  validates :sorting_order, presence: true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0}

  # callbacks
  before_save :process_content_type
  before_destroy :check_dependencies


  # scopes
  scope :all_in_order, -> { order(:sorting_order, :quiz_question_id) }

  # class methods

  # instance methods

  # Setter
  def content_type=(ct)
    @content_type = ct
  end

  # Getter
  def content_type
    if CONTENT_TYPES.include?(@content_type)
      @content_type
    elsif self.contains_image
      'image'
    elsif self.contains_mathjax
      'mathjax'
    else
      'text'
    end
  end

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

  def process_content_type
    if self.content_type == 'image'
      self.contains_image = true
      self.contains_mathjax = false
    elsif self.content_type == 'mathjax'
      self.contains_image = false
      self.contains_mathjax = true
    else
      self.contains_image = false
      self.contains_mathjax = false
    end
    true
  end

  def question_or_answer_only
    if self.quiz_question_id.to_i > 0 && self.quiz_answer_id.to_i > 0
      errors.add(:base, I18n.t('models.quiz_content.can_t_assign_to_question_and_answer'))
    elsif self.quiz_question_id.to_i == 0 && self.quiz_answer_id.to_i == 0
      errors.add(:base, I18n.t('models.quiz_content.must_assign_to_question_or_answer'))
    end
  end

end
