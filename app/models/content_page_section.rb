# == Schema Information
#
# Table name: content_page_sections
#
#  id                :integer          not null, primary key
#  content_page_id   :integer
#  text_content      :text
#  panel_colour      :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  course_id :integer
#  sorting_order     :integer
#

class ContentPageSection < ApplicationRecord
  # Constants

  # relationships
  belongs_to :content_page
  belongs_to :course

  # validation
  validates :content_page_id, presence: true, on: :update
  validates :text_content, presence: true
  validates :panel_colour, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_id) }

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
