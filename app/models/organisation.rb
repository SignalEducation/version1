# == Schema Information
#
# Table name: organisations
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Organisation < ActiveRecord::Base
  validates :name, presence: true

  has_many :subscription_plans
  has_many :subscriptions, through: :subscription_plans
end
