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

class Product < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  enum product_type: { mock_exam: 0, correction_pack: 1, cbe: 2 }

  # Constants

  # relationships
  belongs_to :currency
  belongs_to :mock_exam, optional: true
  belongs_to :cbe, optional: true
  has_many :orders, dependent: :restrict_with_error
  has_many :exercises, dependent: :restrict_with_error

  # validation
  validates :name, presence: true
  validates :currency_id, presence: true
  validates :price, presence: true
  validates :stripe_guid, presence: true, uniqueness: true, on: :update
  validates :stripe_sku_guid, presence: true, uniqueness: true, on: :update
  validates :mock_exam_id, numericality: { only_integer: true,
                                           greater_than: 0 }, if: :mock_exam?
  validates :cbe_id, numericality: { only_integer: true,
                                     greater_than: 0 }, if: :cbe?
  validates :correction_pack_count, presence: true,
                                    numericality: { only_integer: true,
                                                    greater_than: 0 }, if: :correction_pack?

  # callbacks
  after_create :create_on_stripe
  after_update :update_on_stripe

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_active,   -> { where(active: true).includes(mock_exam: :subject_course) }
  scope :in_currency,  ->(ccy_id) { where(currency_id: ccy_id) }
  scope :cbes,         -> { where.not(cbe_id: nil) }
  scope :mock_exams,   -> { where.not(mock_exam_id: nil) }

  # instance methods
  def destroyable?
    orders.empty?
  end

  # class methods
  def self.search(search)
    search.present? ? where('name ILIKE ?', "%#{search}%") : all
  end

  def self.filter_by_state(state)
    case state
    when 'Inactive'
      where(active: false)
    when 'All'
      all
    else
      where(active: true)
    end
  end

  def name_by_type
    cbe? ? cbe.name : mock_exam.name
  end

  private

  def create_on_stripe
    StripeProductWorker.perform_async(id, :create) unless Rails.env.test?
  end

  def update_on_stripe
    StripeProductWorker.perform_async(id, :update) unless Rails.env.test?
  end
end
