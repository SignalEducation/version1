# == Schema Information
#
# Table name: course_module_element_resources
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  name                     :string
#  description              :text
#  web_url                  :string
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string
#  upload_content_type      :string
#  upload_file_size         :integer
#  upload_updated_at        :datetime
#  destroyed_at             :datetime
#

class CourseModuleElementResource < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :course_module_element_id, :name, :description, :web_url, :upload

  # Constants

  # relationships
  belongs_to :course_module_element
  has_attached_file :upload, default_url: '/assets/images/missing.png'

  # validation
  validates :course_module_element_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_id, presence: true, on: :update
  validates :name, presence: true, length: {maximum: 255}
  validates :description, presence: true
  validates_attachment_content_type :upload,
            content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/xlsx application/xls application/doc application/docx application/vnd.openxmlformats-officedocument.wordprocessingml.document)
  validates :web_url, format: {with: URI::regexp(%w(http https)) },
            if: '!web_url.blank?', length: {maximum: 255}
  validate  :web_url_or_upload_required

  # callbacks
  before_validation { squish_fields(:name, :description, :web_url) }
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id).where(destroyed_at: nil) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def web_url_or_upload_required
    if self.web_url.blank? && self.upload.blank? && self.upload_file_name.blank?
      errors.add(:base, I18n.t('models.course_module_element_resources.must_link_with_an_upload_or_url'))
    end
  end

end
