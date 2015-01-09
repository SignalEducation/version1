# == Schema Information
#
# Table name: static_page_uploads
#
#  id                  :integer          not null, primary key
#  description         :string(255)
#  static_page_id      :integer
#  created_at          :datetime
#  updated_at          :datetime
#  upload_file_name    :string(255)
#  upload_content_type :string(255)
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#

class StaticPageUpload < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :description, :static_page_id, :upload,
                  :upload_file_name, :upload_content_type,
                  :upload_updated_at, :upload_file_size

  # Constants

  # relationships
  belongs_to :static_page
  has_attached_file :upload, default_url: '/assets/images/missing.png'

  # validation
  validates :description, presence: true
  validates :static_page_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates_attachment_content_type :upload,
            content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/xlsx application/xls application/doc application/docx application/vnd.openxmlformats-officedocument.wordprocessingml.document)

  # callbacks
  before_validation { squish_fields(:description) }

  # scopes
  scope :all_in_order, -> { order(:description) }
  scope :orphans, -> { where(static_page_id: nil) }
  scope :orphans_or_for_page, lambda { |page_id| where('static_page_id IS NULL or static_page_id = ?', page_id)}

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

end
