# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  created_at               :datetime
#  updated_at               :datetime
#  destroyed_at             :datetime
#  video_id                 :string
#  duration                 :float
#  vimeo_guid               :string
#

class CourseModuleElementVideo < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :course_module_element_id, :video_id, :duration, :vimeo_guid

  # Constants

  # relationships
  belongs_to :course_module_element

  # validation
  validates :course_module_element_id, presence: true, on: :update
  validates :vimeo_guid, presence: true, length: {maximum: 255}, on: :create
  validates :duration, presence: true, numericality: true

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id).where(destroyed_at: nil) }

  # class methods

  # instance methods

  ## Parent & Child associations ##
  def parent
    self.course_module_element
  end

  #######################################################################

  ## Archivable ability ##

  def destroyable?
    true
  end

  protected

end
