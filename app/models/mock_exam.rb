# frozen_string_literal: true
# == Schema Information
#
# Table name: mock_exams
#
#  id                       :integer          not null, primary key
#  course_id        :integer
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

class MockExam < ApplicationRecord
  include LearnSignalModelExtras

  # Constants

  # relationships
  belongs_to :course, optional: true
  has_many :products
  has_many :orders

  has_attached_file :file, default_url: 'images/missing_image.jpg'

  # validation
  validates :name, presence: true
  validates_attachment_content_type :file, content_type: ['application/pdf']

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_id) }

  # class methods

  # instance methods
  def destroyable?
    self.orders.empty?
  end

  protected
  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      throw :abort
    end
  end
end
