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
#  footer_link     :boolean          default("false")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  active          :boolean          default("false")
#

class ContentPage < ApplicationRecord

  # Constants

  # relationships
  has_many :content_page_sections
  has_many :external_banners

  accepts_nested_attributes_for :content_page_sections, allow_destroy: true

  # validation
  validates :name, presence: true, length: {maximum: 255}, uniqueness: true
  validates :public_url, presence: true, length: {maximum: 255}, uniqueness: true
  validates :seo_title, presence: true, length: {maximum: 255}, uniqueness: true
  validates :seo_description, presence: true

  # callbacks
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

  protected


  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
