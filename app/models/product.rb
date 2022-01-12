# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  name                  :string
#  mock_exam_id          :integer
#  stripe_guid           :string
#  live_mode             :boolean          default("false")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  active                :boolean          default("false")
#  currency_id           :integer
#  price                 :decimal(, )
#  stripe_sku_guid       :string
#  course_id             :integer
#  sorting_order         :integer
#  product_type          :integer          default("0")
#  correction_pack_count :integer
#  cbe_id                :bigint
#  group_id              :integer
#  payment_heading       :string
#  payment_subheading    :string
#  payment_description   :text
#  savings_label         :string
#

class Product < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  enum product_type: { mock_exam: 0, correction_pack: 1, cbe: 2, lifetime_access: 3, program_access: 4 }

  # Constants

  # relationships
  belongs_to :currency
  belongs_to :group
  belongs_to :mock_exam, optional: true
  belongs_to :course, optional: true
  belongs_to :cbe, optional: true
  has_many :orders, dependent: :restrict_with_error
  has_many :exercises, dependent: :restrict_with_error
  has_many :faqs, dependent: :restrict_with_error

  accepts_nested_attributes_for :faqs, allow_destroy: true, reject_if: proc { |attributes| attributes['name'].blank? }

  # validation
  validates :name, presence: true
  validates :currency_id, presence: true
  validates :price, presence: true
  validates :stripe_guid, presence: true, uniqueness: true, on: :update
  validates :stripe_sku_guid, presence: true, uniqueness: true, on: :update
  validates :group_id, numericality: { only_integer: true, greater_than: 0 }
  validates :mock_exam_id, numericality: { only_integer: true,
                                           greater_than: 0 }, unless: :non_mock?
  validates :cbe_id, numericality: { only_integer: true,
                                     greater_than: 0 }, if: :cbe?
  validates :correction_pack_count, presence: true,
                                    numericality: { only_integer: true,
                                                    greater_than: 0 }, if: :correction_pack?

  validates :months_to_expiry, presence: true,
                               numericality: { only_integer: true,
                                               greater_than: 0 }, if: :program_access?

  # callbacks
  after_commit :create_on_stripe, on: :create
  after_commit :update_on_stripe, on: :update

  # scopes
  scope :all_in_order,  -> { order(:sorting_order, :name) }
  scope :all_active,    -> { where(active: true) }
  scope :in_currency,   ->(ccy_id) { where(currency_id: ccy_id) }
  scope :cbes,          -> { where.not(cbe_id: nil) }
  scope :mock_exams,    -> { where.not(mock_exam_id: nil) }
  scope :for_group,     ->(group_id) { where(group_id: group_id) }

  # instance methods
  def destroyable?
    orders.empty?
  end

  def name_by_type
    if cbe?
      cbe.name
    elsif lifetime_access?
      "#{group.name} LifeTime Membership"
    elsif program_access?
      course.name.to_s
    else
      mock_exam&.name || name
    end
  end

  def url_by_type
    lifetime_access? ? 'lifetime' : product_type
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

  private

  def non_mock?
    cbe? || lifetime_access? || program_access?
  end

  def create_on_stripe
    StripeProductWorker.perform_async(id, :create) unless Rails.env.test?
  end

  def update_on_stripe
    StripeProductWorker.perform_async(id, :update) unless Rails.env.test?
  end
end
