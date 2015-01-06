# == Schema Information
#
# Table name: raw_video_files
#
#  id                             :integer          not null, primary key
#  file_name                      :string(255)
#  course_module_element_video_id :integer
#  transcode_requested            :boolean          default(FALSE), not null
#  created_at                     :datetime
#  updated_at                     :datetime
#

class RawVideoFile < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :file_name, :course_module_element_video_id, :transcode_requested

  # Constants

  # relationships
  belongs_to :course_module_element_video

  # validation
  validates :file_name, presence: true
  validates :course_module_element_video_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:file_name) }
  scope :not_yet_assigned, -> { where(course_module_element_video_id: nil) }

  # class methods
  def self.get_new_videos
    current_videos = RawVideoFile.all.map(&:file_name)
    stuff_in_aws = [] # todo
    new_items = stuff_in_aws - current_videos
    new_items.each do |item|
      RawVideoFile.create(file_name: item)
    end
  end

  # instance methods
  def destroyable?
    false
  end

  def assign_me_to_cme_video(the_id)
    self.update_attributes(course_module_element_video_id: the_id)
  end

  protected

end
