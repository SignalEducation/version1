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
#  group_id                      :integer
#  subject_course_id             :integer
#

class HomePage < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :seo_title, :seo_description, :subscription_plan_category_id, :public_url, :group_id, :subject_course_id

  # Constants

  # relationships
  belongs_to :subscription_plan_category
  belongs_to :group
  belongs_to :subject_course

  # validation
  validates :seo_title, presence: true, length: {maximum: 255}
  validates :seo_description, allow_nil: true, length: {maximum: 255}
  validates :public_url, presence: true, length: {maximum: 255},
            uniqueness: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:seo_title) }
  scope :for_groups, -> { where.not(group_id: nil) }
  scope :for_courses, -> { where.not(subject_course_id: nil) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def default_home_page
    HomePage.where(group_id: nil).where(subject_course: nil).where(subscription_plan_category_id: nil).where(public_url: '/').first
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
