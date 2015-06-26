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
#

class HomePage < ActiveRecord::Base

  # attr-accessible
  attr_accessible :seo_title, :seo_description, :subscription_plan_category_id, :public_url

  # Constants

  # relationships
  belongs_to :subscription_plan_category

  # validation
  validates :seo_title, presence: true, length: {maximum: 255}
  validates :seo_description, presence: true, length: {maximum: 255}
  validates :subscription_plan_category_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :public_url, presence: true, length: {maximum: 255},
            uniqueness: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:seo_title) }

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
