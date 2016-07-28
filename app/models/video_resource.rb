# == Schema Information
#
# Table name: video_resources
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  question                 :text
#  answer                   :text
#  notes                    :text
#  destroyed_at             :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  transcript               :text
#

class VideoResource < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :question, :answer, :notes, :course_module_element_id, :transcript

  # Constants

  # relationships
  belongs_to :course_module_element, inverse_of: :video_resource

  # validation
  validates  :course_module_element_id, presence: true
  validate  :one_field_set

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:question) }

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

  def one_field_set
    if self.question.blank? && self.answer.blank? && self.notes.blank?
      errors.add(:base, I18n.t('models.video_resources.must_populate_one'))
    end
  end


end
