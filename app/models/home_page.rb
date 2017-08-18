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
#

class HomePage < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :seo_title, :seo_description, :subscription_plan_category_id,
                  :public_url, :subject_course_id, :custom_file_name,
                  :blog_posts_attributes

  # Constants

  # relationships
  belongs_to :subscription_plan_category
  belongs_to :subject_course
  has_many :blog_posts

  accepts_nested_attributes_for :blog_posts, reject_if: lambda { |attributes| nested_resource_is_blank?(attributes) }, allow_destroy: true

  # validation
  validates :seo_title, presence: true, length: {maximum: 255}, uniqueness: true
  validates :seo_description, presence: true, length: {maximum: 255}
  validates :public_url, presence: true, length: {maximum: 255},
            uniqueness: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:seo_title) }
  scope :for_courses, -> { where.not(subject_course_id: nil) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def default_home_page
    HomePage.where(subject_course: nil).where(subscription_plan_category_id: nil).where(public_url: '/').first
  end

  def course
    self.subject_course
  end

  protected

  def self.nested_resource_is_blank?(attributes)
    attributes['title'].blank? &&
        attributes['description'].blank? &&
        attributes['image'].blank? &&
        attributes['url'].blank?
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
