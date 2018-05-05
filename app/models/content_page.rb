# == Schema Information
#
# Table name: content_pages
#
#  id              :integer          not null, primary key
#  name            :string
#  public_url      :string
#  seo_title       :string
#  seo_description :text
#  text_content    :text
#  h1_text         :string
#  h1_subtext      :string
#  nav_type        :string
#  footer_link     :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ContentPage < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :public_url, :seo_title, :seo_description, :text_content,
                  :h1_text, :h1_subtext, :nav_type, :footer_link, :external_banners_attributes

  # Constants
  NAV_OPTIONS = %w(solid transparent)

  # relationships
  has_many :external_banners

  accepts_nested_attributes_for :external_banners, reject_if: lambda { |attributes| banner_nested_resource_is_blank?(attributes) }, allow_destroy: true

  # validation
  validates :name, presence: true, length: {maximum: 255}, uniqueness: true
  validates :public_url, presence: true, length: {maximum: 255}, uniqueness: true
  validates :seo_title, presence: true, length: {maximum: 255}, uniqueness: true
  validates :seo_description, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }
  scope :for_footer, -> { where(footer_link: true) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def standard_nav?
    nav_type == 'solid'
  end

  def transparent_nav?
    nav_type == 'transparent'
  end

  protected

  def self.banner_nested_resource_is_blank?(attributes)
    attributes['name'].blank? &&
        attributes['background_colour'].blank? &&
        attributes['text_content'].blank? &&
        attributes['sorting_order'].blank?
  end


  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
