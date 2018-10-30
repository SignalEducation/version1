# == Schema Information
#
# Table name: content_page_sections
#
#  id              :integer          not null, primary key
#  content_page_id :integer
#  text_content    :text
#  panel_colour    :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ContentPageSection < ActiveRecord::Base

  # attr-accessible
  attr_accessible :content_page_id, :text_content, :panel_colour

  # Constants

  # relationships
  belongs_to :content_page

  # validation
  validates :content_page_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :text_content, presence: true
  validates :panel_colour, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:content_page_id) }

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
