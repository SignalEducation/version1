# == Schema Information
#
# Table name: faq_sections
#
#  id            :integer          not null, primary key
#  name          :string
#  name_url      :string
#  description   :text
#  active        :boolean          default("true")
#  sorting_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class FaqSection < ApplicationRecord

  # Constants

  # relationships
  has_many :faqs

  # validation
  validates :name, allow_nil: true, uniqueness: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true, length: {maximum: 255}
  validates :sorting_order, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_in_order, -> { order(:sorting_order, :name) }

  # class methods

  # instance methods
  def destroyable?
    self.faqs.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
      throw :abort
    end
  end

end
