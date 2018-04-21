# == Schema Information
#
# Table name: external_banners
#
#  id                :integer          not null, primary key
#  name              :string
#  sorting_order     :integer
#  active            :boolean          default(FALSE)
#  background_colour :string
#  text_content      :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class ExternalBanner < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :sorting_order, :active, :background_colour, :text_content

  # Constants

  # relationships

  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :sorting_order, presence: true,
            numericality: {only_integer: true}
  validates :background_colour, presence: true
  validates :text_content, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_in_order, -> { order(:sorting_order, :name) }

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
