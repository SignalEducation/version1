# == Schema Information
#
# Table name: faqs
#
#  id              :integer          not null, primary key
#  name            :string
#  name_url        :string
#  active          :boolean          default("true")
#  sorting_order   :integer
#  faq_section_id  :integer
#  question_text   :text
#  answer_text     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pre_answer_text :text
#  product_id      :integer
#

class Faq < ApplicationRecord

  # Constants

  # relationships
  belongs_to :faq_section, optional: true
  belongs_to :product, optional: true

  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true, length: {maximum: 255}
  validates :sorting_order, presence: true,
            numericality: {only_integer: true}
  validates :faq_section_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :question_text, presence: true
  validates :answer_text, presence: true

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
