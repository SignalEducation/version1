# == Schema Information
#
# Table name: video_resources
#
#  id             :integer          not null, primary key
#  course_step_id :integer
#  question       :text
#  answer         :text
#  notes          :text
#  destroyed_at   :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  transcript     :text
#

class VideoResource < ApplicationRecord
  include LearnSignalModelExtras
  include Archivable

  # Constants

  # relationships
  belongs_to :course_step, inverse_of: :video_resource, optional: true

  # validation
  validates :course_step_id, presence: true, on: :update
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

  def one_field_set
    return unless question.blank? && answer.blank? && notes.blank?

    errors.add(:base, I18n.t('models.video_resources.must_populate_one'))
  end
end
