# == Schema Information
#
# Table name: subject_course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  subject_course_id        :integer
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_upload_file_name    :string
#  file_upload_content_type :string
#  file_upload_file_size    :integer
#  file_upload_updated_at   :datetime
#  external_url             :string
#  active                   :boolean          default(FALSE)
#  sorting_order            :integer
#  available_on_trial       :boolean          default(FALSE)
#

class SubjectCourseResource < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :subject_course_id, :description, :file_upload, :external_url,
                  :active, :sorting_order, :available_on_trial

  # Constants

  # relationships
  belongs_to :subject_course
  has_attached_file :file_upload, default_url: '/assets/images/missing_corporate_logo.png'

  # validation
  validates :name, presence: true
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates_attachment_content_type :file_upload,
                                    content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/xlsx application/xls application/doc application/docx application/vnd.openxmlformats-officedocument.wordprocessingml.document text/csv application/octet-stream application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel.sheet.macroenabled.12 application/vnd.openxmlformats-officedocument.presentationml.presentation text/css)

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_active, -> { where(active: true) }

  # class methods

  # instance methods
  def available_for_subscription(user)

    if user.valid_subscription?
      {view: true, reason: nil}
    else
      self.available_on_trial ? {view: true, reason: nil} : {view: false, reason: 'invalid-subscription'}
    end

  end


  def available_to_user(user)
    result = {view: false, reason: nil}

    case user.account_type

    when 'Trial'
      result = self.available_on_trial ? {view: true, reason: nil} : {view: false, reason: 'trial-restriction'}
    when 'Subscription'
      result = available_for_subscription(user)
    when 'Complimentary'
      result = {view: true, reason: nil}
    else
      result[:reason] = 'account-issue'
    end

    result

    # Return true/false and reason
    # false will display lock icon
    # reason will populate modal
  end

  def destroyable?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
