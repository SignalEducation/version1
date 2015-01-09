# == Schema Information
#
# Table name: vat_rates
#
#  id              :integer          not null, primary key
#  vat_code_id     :integer
#  percentage_rate :float
#  effective_from  :date
#  created_at      :datetime
#  updated_at      :datetime
#

class VatRate < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :vat_code_id, :percentage_rate, :effective_from

  # Constants

  # relationships
  has_many :invoices
  belongs_to :vat_code, inverse_of: :vat_rates

  # validation
  validates :vat_code_id, presence: true,
            numericality: {only_integer: true, greater_than: 0},
            on: :update
  validates :percentage_rate, presence: true
  validates :effective_from, presence: true

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:vat_code_id, :effective_from) }

  # class methods

  # instance methods
  def destroyable?
    # Can be deleted if no invoices are using this code, and
    # the effective_date is in the future
    self.invoices.empty? && self.effective_from > Proc.new{Time.now}.call
  end

  protected

end
