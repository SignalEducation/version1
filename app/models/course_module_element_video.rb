# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                           :integer          not null, primary key
#  course_module_element_id     :integer
#  tags                         :string
#  difficulty_level             :string
#  estimated_study_time_seconds :integer
#  transcript                   :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  destroyed_at                 :datetime
#  video_id                     :string
#  duration                     :float
#  thumbnail                    :text
#

class CourseModuleElementVideo < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :course_module_element_id, :tags, :difficulty_level, :transcript, :video_id, :duration

  # Constants

  # relationships
  belongs_to :course_module_element

  # validation
  validates :course_module_element_id, presence: true, on: :update
  validates :video_id, presence: true, length: {maximum: 255}, on: :create
  #validates :duration, presence: true, numericality: true
  validates :tags, allow_nil: true, length: {maximum: 255}
  validates :difficulty_level, inclusion: {in: ApplicationController::DIFFICULTY_LEVEL_NAMES}, length: {maximum: 255}
  #validates :thumbnail, presence: true

  # callbacks
  before_validation { squish_fields(:tags) }

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id).where(destroyed_at: nil) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def parent
    self.course_module_element
  end

  protected

end
