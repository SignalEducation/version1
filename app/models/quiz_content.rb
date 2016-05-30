# == Schema Information
#
# Table name: quiz_contents
#
#  id                 :integer          not null, primary key
#  quiz_question_id   :integer
#  quiz_answer_id     :integer
#  text_content       :text
#  contains_mathjax   :boolean          default(FALSE), not null
#  contains_image     :boolean          default(FALSE), not null
#  sorting_order      :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  quiz_solution_id   :integer
#  flash_card_id      :integer
#  destroyed_at       :datetime
#

class QuizContent < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :quiz_question_id, :quiz_answer_id, :quiz_solution_id,
                  :text_content, :sorting_order, :content_type, :image,
                  :image_file_name, :image_content_type,
                  :image_file_size, :image_updated_at, :flash_card_id

  # Constants
  CONTENT_TYPES = %w(text image mathjax)

  # relationships
  belongs_to :quiz_answer
  belongs_to :flash_card
  belongs_to :quiz_question
  belongs_to :quiz_solution, class_name: 'QuizQuestion', foreign_key: :quiz_solution_id
  has_attached_file :image, default_url: '/assets/images/missing.png'

  # validation
  validate  :one_parent_only, on: :update
  validates :text_content, presence: true,
            unless: Proc.new{|qc| qc.content_type == 'image' }
  validates :sorting_order, presence: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_validation { squish_fields(:text_content) }
  after_initialize :set_default_values
  before_validation :check_data_consistency

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :quiz_question_id).where(destroyed_at: nil) }
  scope :all_images, -> { where(contains_image: true) }
  scope :all_mathjaxes, -> { where(contains_mathjax: true) }

  # class methods

  # instance methods

  # Setter
  def content_type=(ct)
    @content_type = ct
    if CONTENT_TYPES.include?(ct)
      if ct == 'image'
        self.contains_image = true
        self.contains_mathjax = false
      elsif ct == 'mathjax'
        self.contains_image = false
        self.contains_mathjax = true
      else
        self.contains_image = false
        self.contains_mathjax = false
      end
      true
    else
      false
    end
  end

  # Getter
  def content_type
    if self.contains_image
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

  def check_data_consistency
    #self.content_type == 'image' ? self.text_content = nil : self.image = nil
    true
  end

  def one_parent_only
    test_list = [self.quiz_question_id, self.quiz_answer_id, self.quiz_solution_id, self.flash_card_id].compact # gets rid of "nil"s
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
    self.contains_mathjax ||= false
    self.contains_image ||= false
  end

end
