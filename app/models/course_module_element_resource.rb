# == Schema Information
#
# Table name: course_module_element_resources
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  name                     :string(255)
#  description              :text
#  web_url                  :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string(255)
#  upload_content_type      :string(255)
#  upload_file_size         :integer
#  upload_updated_at        :datetime
#

class CourseModuleElementResource < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :name, :description, :web_url

  # Constants

  # relationships
  belongs_to :course_module_element

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :description, presence: true
  validates :web_url, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

  # class methods

  # instance methods
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
