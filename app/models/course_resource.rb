# == Schema Information
#
# Table name: course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  course_id                :integer
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_upload_file_name    :string
#  file_upload_content_type :string
#  file_upload_file_size    :integer
#  file_upload_updated_at   :datetime
#  external_url             :string
#  active                   :boolean          default("false")
#  sorting_order            :integer
#  available_on_trial       :boolean          default("false")
#  download_available       :boolean          default("false")
#

class CourseResource < ApplicationRecord

  # Constants

  # relationships
  belongs_to :course
  has_attached_file :file_upload, default_url: 'images/missing_image.jpg'

  # validation
  validates :name, presence: true
  validates :course, presence: true
  validates_attachment_content_type :file_upload,
                                    content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/xlsx application/xls application/doc application/docx application/vnd.openxmlformats-officedocument.wordprocessingml.document text/csv application/octet-stream application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel.sheet.macroenabled.12 application/vnd.openxmlformats-officedocument.presentationml.presentation text/css)

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_active, -> { where(active: true) }

  # class methods

  # instance methods
  def available_to_user(user, valid_subscription)
    result =
      if user.non_verified_user?
        { view: false, reason: 'verification-required' }
      elsif user.complimentary_user? || user.non_student_user?
        { view: true, reason: nil }
      elsif user.standard_student_user?
        if valid_subscription
          { view: true, reason: nil }
        else
          available_on_trial ? { view: true, reason: nil } : { view: false, reason: 'invalid-subscription' }
        end
      else
        { view: false, reason: nil }
      end

    result

    # Return true/false and reason
    # false will display lock icon
    # reason will populate modal
  end

  def destroyable?
    true
  end

  def type
    external_url&.blank? ? 'File' : 'Link'
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
