# == Schema Information
#
# Table name: mock_exams
#
#  id                       :integer          not null, primary key
#  subject_course_id        :integer
#  product_id               :integer
#  name                     :string
#  sorting_order            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#

class MockExam < ActiveRecord::Base

  #TODO product_id field should be removed since relationships have changed

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :sorting_order, :file, :cover_image, :subject_course_id

  # Constants

  # relationships
  belongs_to :subject_course
  has_many :products
  has_many :orders

  has_attached_file :file, default_url: '/assets/images/missing.png'
  has_attached_file :cover_image, default_url: '/assets/images/missing.png'

  # validation
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates_attachment_content_type :file, :content_type => ['application/pdf']
  validates_attachment_content_type :cover_image, content_type: %w('image/jpg image/jpeg image/png')

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :subject_course_id) }

  # class methods

  # instance methods
  def destroyable?
    self.orders.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
