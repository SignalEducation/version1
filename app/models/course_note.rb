# == Schema Information
#
# Table name: course_notes
#
#  id                       :integer          not null, primary key
#  course_step_id :integer
#  name                     :string(255)
#  web_url                  :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string(255)
#  upload_content_type      :string(255)
#  upload_file_size         :integer
#  upload_updated_at        :datetime
#  destroyed_at             :datetime
#

class CourseNote < ApplicationRecord
  include LearnSignalModelExtras
  include Archivable

  # Constants

  # relationships
  belongs_to :course_step
  has_attached_file :upload

  # validation
  validates :course_step_id, presence: true, on: :update
  validates :name, presence: true, length: { maximum: 255 }
  validates_attachment_content_type :upload,
                                    content_type: %w[application/pdf]

  # callbacks
  before_validation { squish_fields(:name) }
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_step_id).where(destroyed_at: nil) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def type
    web_url ? 'External Link' : 'File Upload'
  end

  def duplicate
    new_cme_note = deep_clone include: :course_step, validate: false

    new_cme_note.
      course_step.update(name: "#{course_step.name} COPY",
                                   name_url: "#{course_step.name_url}_copy",
                                   active: false)
  end
end
