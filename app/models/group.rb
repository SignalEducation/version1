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
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  destroyed_at                  :datetime
#  image_file_name               :string
#  image_content_type            :string
#  image_file_size               :integer
#  image_updated_at              :datetime
#  background_image_file_name    :string
#  background_image_content_type :string
#  background_image_file_size    :integer
#  background_image_updated_at   :datetime
#  background_colour             :string
#  exam_body_id                  :bigint(8)
#  seo_title                     :string
#  seo_description               :string
#  short_description             :string
#

class Group < ApplicationRecord

  include LearnSignalModelExtras
  include Archivable

  # Constants

  # relationships
  belongs_to :exam_body
  has_many :subject_courses
  has_many :home_pages
  has_attached_file :image, default_url: 'courses-AAT.jpg'
  has_attached_file :background_image, default_url: 'bg_library_group.jpg'


  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true, length: {maximum: 255}
  validates :description, presence: true
  validates :short_description, presence: true, length: {maximum: 255}
  validates :seo_title, presence: true, uniqueness: true, length: {maximum: 255}
  validates :seo_description, presence: true, length: {maximum: 255}
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  validates_attachment_content_type :background_image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_active, -> { where(active: true) }

  # class methods

  # instance methods

  ## Parent & Child associations ##
  def active_children
    children.try(:all_active)
  end

  def children
    self.try(:subject_courses)
  end


  #######################################################################

  ## Archivable ability ##

  def destroyable?
    true
  end

  def destroyable_children
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
