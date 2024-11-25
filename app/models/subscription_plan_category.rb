# == Schema Information
#
# Table name: subscription_plan_categories
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  available_from   :datetime
#  available_to     :datetime
#  guid             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  sub_heading_text :string
#

class SubscriptionPlanCategory < ApplicationRecord
  include LearnSignalModelExtras

  # Constants

  # relationships
  has_many :subscription_plans

  # validation
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :available_from, presence: true
  validates :available_to, presence: true
  validates :guid, presence: true

  # callbacks
  before_validation { squish_fields(:name) }
  before_validation :set_guid, on: :create

  # scopes
  scope :all_in_order, -> { order(:name) }
  scope :active_with_guid, lambda { |the_guid| where(guid: the_guid).where('available_from < :now AND available_to > :now', {now: Proc.new{Time.now}.call} )}

  # class methods

  # instance methods
  def destroyable?
    self.subscription_plans.empty?
  end

  def current
    self.available_from < Proc.new{Time.now}.call && self.available_to > Proc.new{Time.now}.call
  end

  def full_name
    self.name + ' - ' +
            self.available_from.strftime(I18n.t('controllers.application.date_formats.standard')) + ' - ' +
            self.available_to.strftime(I18n.t('controllers.application.date_formats.standard'))
  end

  def status
    self.current ? 'success' : ''
  end

  protected

  def set_guid
    self.guid = ApplicationController.generate_random_code(10)
  end

end
