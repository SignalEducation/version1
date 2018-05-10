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
#  active          :boolean          default(FALSE)
#

class ContentPage < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :public_url, :seo_title, :seo_description, :text_content,
                  :h1_text, :h1_subtext, :nav_type, :footer_link, :active,
                  :external_banners_attributes

  # Constants
  NAV_OPTIONS = %w(solid transparent)

  # relationships
  has_many :external_banners

  accepts_nested_attributes_for :external_banners, allow_destroy: true, limit: 1

  # validation
  validates :name, presence: true, length: {maximum: 255}, uniqueness: true
  validates :public_url, presence: true, length: {maximum: 255}, uniqueness: true
  validates :seo_title, presence: true, length: {maximum: 255}, uniqueness: true
  validates :seo_description, presence: true

  # callbacks
  before_validation :remove_empty_banner
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }
  scope :all_active, -> { where(active: true) }
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

  def remove_empty_banner
    #Since the editor will always populate the text_content field
    #we must clear the entire record when no name attribute is present
    #to allow content_page records be created without nested banners
    if self.external_banners[0].name.blank?
      self.external_banners[0].destroy
    end
  end


  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
