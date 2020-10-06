# == Schema Information
#
# Table name: exam_bodies
#
#  id                                 :integer          not null, primary key
#  name                               :string
#  url                                :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  active                             :boolean          default("false"), not null
#  has_sittings                       :boolean          default("false"), not null
#  preferred_payment_frequency        :integer
#  subscription_page_subheading_text  :string
#  constructed_response_intro_heading :string
#  constructed_response_intro_text    :text
#  logo_image                         :string
#  registration_form_heading          :string
#  login_form_heading                 :string
#  audience_guid                      :string
#  landing_page_h1                    :string
#  landing_page_paragraph             :text
#  has_products                       :boolean          default("false")
#  products_heading                   :string
#  products_subheading                :text
#  products_seo_title                 :string
#  products_seo_description           :string
#  emit_certificate                   :boolean          default("false")
#  pricing_heading                    :string
#  pricing_subheading                 :string
#  pricing_seo_title                  :string
#  pricing_seo_description            :string
#  hubspot_property                   :string
#

class ExamBody < ApplicationRecord

  LOGO_IMAGES = %w(learning-partner-badge.png acca_approved_white.png acca_approved_red.png ALP_LOGO_(GOLD).png ALP_LOGO_GOLD_REVERSED.png CIMA_logo.png CIMA_logo_black.png CIMA_logo_small.png AAT_Approved.png).freeze

  has_one :group
  has_many :coupons
  has_many :enrollments
  has_many :exam_sittings
  has_many :courses
  has_many :exam_body_user_details
  has_many :subscription_plans
  has_many :products

  validates :name, presence: true, uniqueness: true
  validates :hubspot_property, presence: true, uniqueness: true
  validates :landing_page_h1, :landing_page_paragraph, :products_heading, presence: true
  validate :check_hubspot_property

  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { includes(:group).order('groups.sorting_order') }

  scope :all_active,        -> { where(active: true) }
  scope :all_with_sittings, -> { where(has_sittings: true) }

  # instance methods
  def destroyable?
    exam_sittings.empty? && enrollments.empty? && courses.empty?
  end

  def to_s
    name
  end

  def help_text
    has_sittings ? 'Ask the Tutor' : 'Need Help'
  end

  def group
    Group.find_by(exam_body_id: id)
  end

  def check_hubspot_property
    return if Rails.env.test?
    return if HubSpot::Properties.new.exists?(hubspot_property)

    errors.add(:hubspot_property, 'should be added in hubspot first.')
  end

  private

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      throw :abort
    end
  end
end
