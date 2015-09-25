# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                           :integer          not null, primary key
#  course_module_element_id     :integer
#  raw_video_file_id            :integer
#  tags                         :string
#  difficulty_level             :string
#  estimated_study_time_seconds :integer
#  transcript                   :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  destroyed_at                 :datetime
#  video_id                     :string
#

class CourseModuleElementVideo < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :course_module_element_id, :raw_video_file_id, :tags, :difficulty_level, :transcript, :video_id

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :raw_video_file

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :raw_video_file_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :video_id, presence: true, length: {maximum: 255}
  validates :tags, presence: true, length: {maximum: 255}
  validates :difficulty_level, inclusion: {in: ApplicationController::DIFFICULTY_LEVEL_NAMES}, length: {maximum: 255}
  validates :transcript, presence: true

  # callbacks
  before_validation { squish_fields(:tags) }
  before_update :set_estimated_study_time

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id).where(destroyed_at: nil) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def set_estimated_study_time
    self.estimated_study_time_seconds = self.course_module_element.try(:estimated_time_in_seconds).to_i *
        ApplicationController.find_multiplier_for_difficulty_level(self.difficulty_level)
  end

  def post_video_to_wistia(name, path_to_video)
    require 'net/http'
    require 'net/http/post/multipart'
    require 'json'
    uri = URI('https://upload.wistia.com/')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # Construct the request.
    request = Net::HTTP::Post::Multipart.new uri.request_uri, {
                                                                api_password: ENV['learnsignal_wistia_api_key'],
                                                                name: self.course_module_element.name.to_s,
                                                                project_id: self.course_module_element.parent.parent.wistia_guid.to_s,

                                                                file: UploadIO.new(
                                                                    File.open(path_to_video),
                                                                    'application/octet-stream',
                                                                    File.basename(path_to_video)
                                                                )
                                                            }
    # Make it so!
    response = http.request(request)

    return response
  end

  protected

end
