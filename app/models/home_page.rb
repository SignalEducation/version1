# == Schema Information
#
# Table name: home_pages
#
#  id                            :integer          not null, primary key
#  seo_title                     :string
#  seo_description               :string
#  subscription_plan_category_id :integer
#  public_url                    :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  subject_course_id             :integer
#  custom_file_name              :string
#  group_id                      :integer
#  name                          :string
#  discourse_ids                 :string
#  home                          :boolean          default(FALSE)
#  header_heading                :string
#  header_paragraph              :text
#  header_button_text            :string
#  background_image              :string
#  header_button_link            :string
#  header_button_subtext         :string
#  footer_link                   :boolean          default(FALSE)
#  mailchimp_list_guid           :string
#  mailchimp_section_heading     :string
#  mailchimp_section_subheading  :string
#  mailchimp_subscribe_section   :boolean          default(FALSE)
#

class HomePage < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :seo_title, :seo_description, :subscription_plan_category_id,
                  :public_url, :subject_course_id, :custom_file_name,
                  :blog_posts_attributes, :group_id, :name, :home, :external_banners_attributes,
                  :header_heading, :header_paragraph, :header_button_text, :background_image,
                  :header_button_link, :header_button_subtext, :footer_link, :mailchimp_list_guid,
                  :mailchimp_section_heading, :mailchimp_section_subheading, :mailchimp_subscribe_section

  # Constants
  BACKGROUND_IMAGES = %w(watch_person highlighter_person lamp_person glasses_person meeting_persons)

  # relationships
  belongs_to :subscription_plan_category
  belongs_to :group
  belongs_to :subject_course
  has_many :blog_posts
  has_many :external_banners

  accepts_nested_attributes_for :blog_posts, reject_if: lambda { |attributes| blog_nested_resource_is_blank?(attributes) }, allow_destroy: true
  accepts_nested_attributes_for :external_banners, reject_if: lambda { |attributes| banner_nested_resource_is_blank?(attributes) }, allow_destroy: true

  # validation
  validates :name, presence: true, length: {maximum: 255}, uniqueness: true
  validates :seo_title, presence: true, length: {maximum: 255}, uniqueness: true
  validates :seo_description, presence: true, length: {maximum: 255}
  validates :public_url, presence: true, length: {maximum: 255},
            uniqueness: true

  validate :group_xor_course
  #TODO add custom validation to ensure only one can be 'home: true'


  # callbacks
  before_validation :remove_empty_banner
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:seo_title) }
  scope :for_courses, -> { where.not(subject_course_id: nil) }
  scope :for_groups, -> { where.not(group_id: nil) }
  scope :for_footer, -> { where(footer_link: true) }

  # class methods

  # instance methods
  def destroyable?
    true unless self.home
  end

  def default_home_page
    HomePage.where(subject_course: nil).where(home: true).where(subscription_plan_category_id: nil).first
  end

  def course
    self.subject_course
  end

  protected

  def self.blog_nested_resource_is_blank?(attributes)
    attributes['title'].blank? &&
        attributes['description'].blank? &&
        attributes['image'].blank? &&
        attributes['url'].blank?
  end

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

  def group_xor_course
    unless group_id.blank? ^ subject_course_id.blank?
      errors.add(:base, 'Select a Group or a Course, not both')
    end
  end

  def remove_empty_banner
    #Since the editor will always populate the text_content field
    #we must clear the entire record when no name attribute is present
    #to allow content_page records be created without nested banners
    if self.external_banners[0].name.blank?
      self.external_banners[0].destroy
    end
  end

end
