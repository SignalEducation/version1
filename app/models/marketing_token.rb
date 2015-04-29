# == Schema Information
#
# Table name: marketing_tokens
#
#  id                    :integer          not null, primary key
#  code                  :string(255)
#  marketing_category_id :integer
#  is_hard               :boolean          default(FALSE), not null
#  is_direct             :boolean          default(FALSE), not null
#  is_seo                :boolean          default(FALSE), not null
#  created_at            :datetime
#  updated_at            :datetime
#

class MarketingToken < ActiveRecord::Base

  # attr-accessible
  attr_accessible :code, :marketing_category_id, :is_hard

  # Constants

  # relationships
  belongs_to :marketing_category

  # validation
  validates :code, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\w+/ }
  validates :marketing_category_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:code) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

end
