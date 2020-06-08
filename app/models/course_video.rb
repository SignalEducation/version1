# frozen_string_literal: true

# == Schema Information
#
# Table name: course_videos
#
#  id             :integer          not null, primary key
#  course_step_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  destroyed_at   :datetime
#  video_id       :string
#  duration       :float
#  vimeo_guid     :string
#  dacast_id      :string
#

class CourseVideo < ApplicationRecord
  include LearnSignalModelExtras
  include Archivable

  # Constants

  # relationships
  belongs_to :course_step

  # validation
  validates :course_step_id, presence: true, on: :update
  validates :vimeo_guid, presence: true, length: { maximum: 255 }, on: :create
  validates :duration, presence: true, numericality: true
  validates :vimeo_guid, :dacast_id,
            presence: true, if: lambda {
              course_step&.active && course_step&.is_video
            }


  # scopes
  scope :all_in_order, -> { order(:course_step_id).where(destroyed_at: nil) }

  def parent
    course_step
  end


  def destroyable?
    true
  end

  def duplicate
    new_cme_video = deep_clone include: :course_step, validate: false

    new_cme_video.
      course_step.update(name: "#{course_step.name} COPY",
                                   name_url: "#{course_step.name_url}_copy",
                                   active: false)
  end
end
