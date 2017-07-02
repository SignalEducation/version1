# == Schema Information
#
# Table name: quiz_contents
#
#  id                 :integer          not null, primary key
#  quiz_question_id   :integer
#  quiz_answer_id     :integer
#  text_content       :text
#  sorting_order      :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  quiz_solution_id   :integer
#  destroyed_at       :datetime
#

class QuizContent < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :quiz_question_id, :quiz_answer_id, :quiz_solution_id,
                  :text_content, :sorting_order, :image, :image_file_name,
                  :image_content_type, :image_file_size, :image_updated_at

  # Constants

  # relationships
  belongs_to :quiz_answer
  belongs_to :quiz_question
  belongs_to :quiz_solution, class_name: 'QuizQuestion', foreign_key: :quiz_solution_id
  has_attached_file :image, default_url: '/assets/images/missing.png'

  # validation
  validate  :one_parent_only, on: :update
  validates :text_content, presence: true
  validates :sorting_order, presence: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_validation { squish_fields(:text_content) }
  after_initialize :set_default_values

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :quiz_question_id).where(destroyed_at: nil) }

  # class methods

  # instance methods

  def destroyable?
    true
  end

  protected

  def one_parent_only
    test_list = [self.quiz_question_id, self.quiz_answer_id, self.quiz_solution_id].compact # gets rid of "nil"s
    if test_list.length > 1
      errors.add(:base, I18n.t('models.quiz_content.can_t_assign_to_multiple_things'))
    elsif test_list.length == 0
      errors.add(:base, I18n.t('models.quiz_content.must_assign_to_at_least_one_thing'))
    else
      true
    end
  end

  def set_default_values
    self.sorting_order ||= 1
  end

end
