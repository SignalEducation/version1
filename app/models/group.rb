# == Schema Information
#
# Table name: groups
#
#  id                            :integer          not null, primary key
#  name                          :string
#  name_url                      :string
#  active                        :boolean          default(FALSE), not null
#  sorting_order                 :integer
#  description                   :text
#  subject_id                    :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  corporate_customer_id         :integer
#  destroyed_at                  :datetime
#  image_file_name               :string
#  image_content_type            :string
#  image_file_size               :integer
#  image_updated_at              :datetime
#  background_colour             :string
#  background_image_file_name    :string
#  background_image_content_type :string
#  background_image_file_size    :integer
#  background_image_updated_at   :datetime
#

class Group < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :name, :name_url, :active, :sorting_order, :description, :subject_id, :image, :background_colour, :corporate_customer_id, :background_image

  # Constants

  # relationships
  #belongs_to :subject
  has_and_belongs_to_many :subject_courses
  has_many :home_pages
  has_attached_file :image, default_url: "missing_corporate_logo.png"


  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true, length: {maximum: 255}
  validates :description, presence: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_active, -> { where(active: true) }
  scope :for_corporates, -> { where.not(corporate_customer_id: nil) }
  scope :for_public, -> { where(corporate_customer_id: nil) }

  # class methods

  # instance methods
  def active_children
    children.try(:all_active)
  end

  def live_children
    children.try(:all_live)
  end

  def children
    self.try(:subject_courses)
  end

  def destroyable?
    true
  end

  def destroyable_children
    # not destroyable:
    # - self.course_module_element_user_logs
    # - self.student_exam_tracks.empty?
    the_list = []
    the_list += self.subject_courses.to_a
    the_list
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
