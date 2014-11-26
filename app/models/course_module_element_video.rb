# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                           :integer          not null, primary key
#  course_module_element_id     :integer
#  raw_video_file_id            :integer
#  tags                         :string(255)
#  difficulty_level             :string(255)
#  estimated_study_time_seconds :integer
#  transcript                   :text
#  created_at                   :datetime
#  updated_at                   :datetime
#

class CourseModuleElementVideo < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :raw_video_file_id, :tags, :difficulty_level, :estimated_study_time_seconds, :transcript

  # Constants
  BASE_URL = "https://learnsignal_video_assets.eu-west-1.amazonaws.com/#{Rails.env}/"

  # relationships
  belongs_to :course_module_element
  belongs_to :raw_video_file

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :raw_video_file_id, presence: true, uniqueness: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :tags, presence: true
  validates :difficulty_level, inclusion: {in: ApplicationController::DIFFICULTY_LEVEL_NAMES}
  validates :estimated_study_time_seconds, presence: true
  validates :transcript, presence: true

  # callbacks
  before_update :set_estimated_study_time
  after_save :update_raw_video_file
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end


  def set_estimated_study_time
    self.estimated_study_time_seconds = self.course_module_element.try(:estimated_time_in_seconds).to_i *
        ApplicationController.find_multiplier_for_difficulty_level(self.difficulty_level)
  end

  def url(format)
    BASE_URL + "#{self.id}/#{format}.mp4"
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def update_raw_video_file
    self.raw_video_file.assign_me_to_cme_video(self.id)
  end
end
