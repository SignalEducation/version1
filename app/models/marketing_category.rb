# == Schema Information
#
# Table name: marketing_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class MarketingCategory < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name

  # Constants

  # relationships
  has_many :marketing_tokens

  # validation
  validates :name, presence: true, uniqueness: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }

  # class methods

  # instance methods
  def destroyable?
    self.marketing_tokens.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
