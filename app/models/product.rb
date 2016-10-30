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
  attr_accessible :name, :subject_course_id, :mock_exam_id, :active, :currency_id, :price, :stripe_sku_guid, :live_mode, :stripe_guid

  # Constants

  # relationships
  belongs_to :subject_course
  belongs_to :currency
  belongs_to :mock_exam
  has_many :orders

  # validation
  validates :name, presence: true
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_guid, presence: true, uniqueness: true, on: :update
  validates :currency_id, presence: true
  validates :price, presence: true
  validates :stripe_sku_guid, presence: true, uniqueness: true, on: :update

  # callbacks
  after_create :create_on_stripe
  after_update :update_on_stripe
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

  def create_on_stripe
    stripe_product = Stripe::Product.create(name: self.name, shippable: false, active: self.active)
    self.live_mode = stripe_product.livemode
    self.stripe_guid = stripe_product.id

    stripe_sku = Stripe::SKU.create(
        currency: self.currency.iso_code,
        price: (self.price.to_f * 100).to_i,
        product: self.stripe_guid,
        active: self.active,
        inventory: {
            type: 'infinite'
        }
    )
    self.stripe_sku_guid = stripe_sku.id
    self.save!
  end

  def update_on_stripe
    stripe_product = Stripe::Product.retrieve(id: self.stripe_guid)
    stripe_product.name = self.name
    stripe_product.active = self.active
    stripe_product.save

  rescue => e
    errors.add(:stripe, e.message)
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
