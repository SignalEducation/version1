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
#  home                          :boolean          default(FALSE)
#  logo_image                    :string
#  footer_link                   :boolean          default(FALSE)
#  mailchimp_list_guid           :string
#  registration_form             :boolean          default(FALSE), not null
#  pricing_section               :boolean          default(FALSE), not null
#  seo_no_index                  :boolean          default(FALSE), not null
#  login_form                    :boolean          default(FALSE), not null
#  preferred_payment_frequency   :integer
#  header_h1                     :string
#  header_paragraph              :string
#  registration_form_heading     :string
#  login_form_heading            :string
#  footer_option                 :string           default("white")
#  video_guid                    :string
#

class HomePage < ActiveRecord::Base

  include LearnSignalModelExtras

  # Constants
  LOGO_IMAGES = %w(learning-partner-badge.png acca_approved_white.png acca_approved_red.png ALP_LOGO_(GOLD).png ALP_LOGO_GOLD_REVERSED.png)
  FOOTER_OPTIONS = %w(white dark)

  # relationships
  belongs_to :subscription_plan_category, optional: true
  belongs_to :group, optional: true
  belongs_to :subject_course, optional: true
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

  validate :group_xor_course, unless: :home


  # callbacks
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
  
end
