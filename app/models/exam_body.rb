# == Schema Information
#
# Table name: exam_bodies
#
#  id                                 :integer          not null, primary key
#  name                               :string
#  url                                :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  active                             :boolean          default(FALSE), not null
#  has_sittings                       :boolean          default(FALSE), not null
#  preferred_payment_frequency        :integer
#  subscription_page_subheading_text  :string
#  constructed_response_intro_heading :string
#  constructed_response_intro_text    :text
#  logo_image                         :string
#  registration_form_heading          :string
#  login_form_heading                 :string
#

class ExamBody < ApplicationRecord

  LOGO_IMAGES = %w(learning-partner-badge.png acca_approved_white.png acca_approved_red.png ALP_LOGO_(GOLD).png ALP_LOGO_GOLD_REVERSED.png)

  has_one :group
  has_many :enrollments
  has_many :exam_sittings
  has_many :subject_courses
  has_many :exam_body_user_details
  has_many :subscription_plans

  validates :name, presence: true, uniqueness: true
  validates :url, presence: true
  #validates :constructed_response_intro_heading, presence: true
  #validates :constructed_response_intro_text, presence: true

  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }
  scope :all_active, -> { where(active: true) }
  scope :all_with_sittings, -> { where(has_sittings: true) }

  # instance methods
  def destroyable?
    self.exam_sittings.empty? && self.enrollments.empty? && self.subject_courses.empty?
  end

  def to_s
    name
  end

  private

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      throw :abort
    end
  end
end
