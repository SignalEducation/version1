# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  name                  :string
#  mock_exam_id          :integer
#  stripe_guid           :string
#  live_mode             :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  active                :boolean          default(FALSE)
#  currency_id           :integer
#  price                 :decimal(, )
#  stripe_sku_guid       :string
#  subject_course_id     :integer
#  sorting_order         :integer
#  product_type          :integer          default("mock_exam")
#  correction_pack_count :integer
#

class Product < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include LearnSignalModelExtras
  enum product_type: { mock_exam: 0, correction_pack: 1 }

  # Constants

  # relationships
  belongs_to :currency
  belongs_to :mock_exam
  has_many :orders
  has_many :exercises

  # validation
  validates :name, presence: true
  validates :mock_exam_id, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :currency_id, presence: true
  validates :price, presence: true
  validates :stripe_guid, presence: true, uniqueness: true, on: :update
  validates :stripe_sku_guid, presence: true, uniqueness: true, on: :update
  validates :correction_pack_count,
              presence: true,
              numericality: {
                only_integer: true, greater_than: 0
              }, if: Proc.new { |prod| prod.correction_pack? }

  # callbacks
  after_create :create_on_stripe
  after_update :update_on_stripe
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_active, -> { where(active: true).includes(mock_exam: :subject_course) }
  scope :in_currency, lambda { |ccy_id| where(currency_id: ccy_id) }

  # class methods

  # instance methods
  def destroyable?
    self.orders.empty?
  end

  def self.search(search)
    return where('name ILIKE ?', "%#{search}%") if search.present?

    Product.all_active.all_in_order
  end

  ## Creates product object on stripe and updates attributes here with response data ##
  def create_on_stripe
    unless Rails.env.test?
      stripe_product = Stripe::Product.create(name: self.name,
                                              shippable: false,
                                              active: self.active)
      self.live_mode = stripe_product.livemode
      self.stripe_guid = stripe_product.id

      stripe_sku = Stripe::SKU.create(product: stripe_product.id,
                                      currency: self.currency.iso_code,
                                      price: (self.price.to_f * 100).to_i,
                                      active: true,
                                      inventory: { type: 'infinite' })
      self.stripe_sku_guid = stripe_sku.id
      self.save!
    end
  end

  ## Updates stripe product object ##
  def update_on_stripe
    unless Rails.env.test?
      stripe_product = Stripe::Product.retrieve(id: self.stripe_guid)
      stripe_product.name = self.name
      stripe_product.active = self.active
      stripe_product.save
    end
  rescue => e
    errors.add(:stripe, e.message)
    false
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
