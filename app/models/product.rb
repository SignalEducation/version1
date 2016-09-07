# == Schema Information
#
# Table name: products
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  mock_exam_id      :integer
#  stripe_guid       :string
#  live_mode         :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  active            :boolean          default(FALSE)
#  currency_id       :integer
#  price             :decimal(, )
#  stripe_sku_guid   :string
#

class Product < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :subject_course_id, :mock_exam_id, :active, :currency_id, :price, :stripe_sku_guid

  # Constants

  # relationships
  belongs_to :subject_course
  belongs_to :currency
  #belongs_to :mock_exam
  has_many :orders

  # validation
  validates :name, presence: true
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_guid, presence: true, uniqueness: true
  validates :currency_id, presence: true
  validates :price, presence: true
  validates :stripe_sku_guid, presence: true, uniqueness: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }
  scope :all_active, -> { where(active: true) }
  scope :in_currency, lambda { |ccy_id| where(currency_id: ccy_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
