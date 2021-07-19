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
#  course_id                     :integer
#  custom_file_name              :string
#  group_id                      :integer
#  name                          :string
#  home                          :boolean          default("false")
#  logo_image                    :string
#  footer_link                   :boolean          default("false")
#  mailchimp_list_guid           :string
#  registration_form             :boolean          default("false"), not null
#  pricing_section               :boolean          default("false"), not null
#  seo_no_index                  :boolean          default("false"), not null
#  login_form                    :boolean          default("false"), not null
#  preferred_payment_frequency   :integer
#  header_h1                     :string
#  header_paragraph              :string
#  registration_form_heading     :string
#  login_form_heading            :string
#  footer_option                 :string           default("white")
#  video_guid                    :string
#  header_h3                     :string
#  background_image              :string
#  usp_section                   :boolean          default("true")
#  stats_content                 :text
#  course_description            :text
#  header_description            :text
#  onboarding_welcome_heading    :string
#  onboarding_welcome_subheading :text
#  onboarding_level_heading      :string
#  onboarding_level_subheading   :text
#

class HomePage < ApplicationRecord

  include LearnSignalModelExtras

  # Constants
  LOGO_IMAGES = %w[learning-partner-badge.png acca_approved_white.png acca_approved_red.png ALP_LOGO_(GOLD).png ALP_LOGO_GOLD_REVERSED.png CIMA_logo_small.png AAT_Approved.png CIMA_Registered_Tuition_Provider_RGB.png FRM_logo.png].freeze
  TEMPLATES = %w[default.html.haml basic_registration.html.haml basic_login.html.haml pricing_plans.html.haml preferred_plan.html.haml bootcamp.html.haml podcast.html.haml open_week.html.haml resources.html.haml about_us.html.haml testimonials.html.haml careers.html.haml course_registration.html.haml].freeze
  BG_IMAGES = %w[hero-bg.jpg hero-bg-1.jpg hero-bg-2.jpg hero-bg-3.jpg hero-bg-4.jpg hero-bg-5.jpg hero-bg-6.jpg hero-bg-7.jpg hero-bg-8.jpg black-bg.jpg black-friday-bg.jpg blue-background.png green-background.png alt-black-background.png blue-green-background.png red-background.png course-bg.jpg].freeze
  FOOTER_OPTIONS = %w[white dark].freeze

  # relationships
  belongs_to :subscription_plan_category, optional: true
  belongs_to :group, optional: true
  belongs_to :course, optional: true
  has_many :blog_posts
  has_many :external_banners
  has_many :student_testimonials
  has_many :users

  accepts_nested_attributes_for :blog_posts, reject_if: lambda { |attributes| blog_nested_resource_is_blank?(attributes) }, allow_destroy: true
  accepts_nested_attributes_for :external_banners, reject_if: lambda { |attributes| banner_nested_resource_is_blank?(attributes) }, allow_destroy: true
  accepts_nested_attributes_for :student_testimonials, reject_if: lambda { |attributes| student_testimonial_nested_resource_is_blank?(attributes) }, allow_destroy: true

  # validation
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :seo_title, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :seo_description, presence: true, length: { maximum: 255 }
  validates :public_url, presence: true, length: { maximum: 255 }, uniqueness: true


  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:seo_title) }
  scope :for_courses, -> { where.not(course_id: nil) }
  scope :for_groups, -> { where.not(group_id: nil) }
  scope :for_footer, -> { where(footer_link: true) }

  # class methods

  # instance methods
  def destroyable?
    true unless home
  end

  def default_home_page
    HomePage.where(course: nil).where(home: true).where(subscription_plan_category_id: nil).first
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

  def self.student_testimonial_nested_resource_is_blank?(attributes)
    attributes['text'].blank? &&
        attributes['signature'].blank? &&
        attributes['sorting_order'].blank?
  end

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end
end
