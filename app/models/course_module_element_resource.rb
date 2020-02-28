# == Schema Information
#
# Table name: course_module_element_resources
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
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

class CourseModuleElementResource < ApplicationRecord

  include LearnSignalModelExtras
  include Archivable

  # Constants

  # relationships
  belongs_to :course_module_element
  has_attached_file :upload

  # validation
  validates :course_module_element_id, presence: true, on: :update
  validates :name, presence: true, length: {maximum: 255}
  validates_attachment_content_type :upload,
            content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/xlsx application/xls application/doc application/docx application/vnd.openxmlformats-officedocument.wordprocessingml.document text/csv application/octet-stream application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel.sheet.macroenabled.12 application/vnd.openxmlformats-officedocument.presentationml.presentation text/css)

  # callbacks
  before_validation { squish_fields(:name) }
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id).where(destroyed_at: nil) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def type
    self.web_url ? 'External Link' : 'File Upload'
  end

  protected

end
