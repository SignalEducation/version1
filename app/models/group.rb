# == Schema Information
#
# Table name: groups
#
#  id                            :integer          not null, primary key
#  name                          :string
#  name_url                      :string
#  active                        :boolean          default("false"), not null
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
#  exam_body_id                  :bigint
#  background_colour             :string
#  seo_title                     :string
#  seo_description               :string
#  short_description             :string
#  onboarding_level_subheading   :text
#  onboarding_level_heading      :string
#  tab_view                      :boolean          default("false"), not null
#  disclaimer                    :text
#

class Group < ApplicationRecord
  include LearnSignalModelExtras
  include Archivable

  # Constants

  # relationships
  belongs_to :exam_body
  belongs_to :category
  belongs_to :sub_category, optional: true
  has_many :courses
  has_many :home_pages
  has_many :levels
  has_many :key_areas
  has_attached_file :image, default_url: 'courses-AAT.jpg'
  has_attached_file :background_image, default_url: 'bg_library_group.jpg'

  # validation
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :name_url, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :short_description, presence: true, length: { maximum: 255 }
  validates :onboarding_level_heading, presence: true
  validates :seo_title, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :seo_description, presence: true, length: { maximum: 255 }
  validates :category_id, presence: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  validates_attachment_content_type :background_image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_save :filter_disclaimer_text
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_active, -> { where(active: true) }
  scope :with_active_body, -> { joins(:exam_body).where(exam_bodies: { active: true }) }

  # class methods

  # instance methods

  ## Parent & Child associations ##
  def active_children
    children.try(:all_active)
  end

  def children
    self.try(:courses)
  end

  #######################################################################

  ## Archivable ability ##

  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list += self.courses.to_a
    the_list
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def self.level_nested_resource_is_blank?(attributes)
    attributes['name'].blank? && attributes['name_url'].blank?
  end

  def filter_disclaimer_text
    return unless attributes['disclaimer'].blank? || attributes['disclaimer'] == '<p><br></p>'

    self.disclaimer = nil
  end
end
