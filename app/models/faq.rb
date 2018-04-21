# == Schema Information
#
# Table name: faqs
#
#  id              :integer          not null, primary key
#  name            :string
#  name_url        :string
#  active          :boolean          default(TRUE)
#  sorting_order   :integer
#  faq_section_id  :integer
#  question_text   :text
#  answer_text     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pre_answer_text :text
#

class Faq < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :name_url, :active, :sorting_order, :faq_section_id, :question_text,
                  :answer_text, :pre_answer_text

  # Constants

  # relationships
  belongs_to :faq_section

  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true, length: {maximum: 255}
  validates :sorting_order, presence: true
  validates :faq_section_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :question_text, presence: true
  validates :pre_answer_text, presence: true
  validates :answer_text, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_in_order, -> { order(:sorting_order, :name) }

  # class methods

  # instance methods
  def destroyable?
    !self.active
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
