# == Schema Information
#
# Table name: visits
#
#  id               :uuid             not null, primary key
#  visitor_id       :uuid
#  ip               :string
#  user_agent       :text
#  referrer         :text
#  landing_page     :text
#  user_id          :integer
#  referring_domain :string
#  search_keyword   :string
#  browser          :string
#  os               :string
#  device_type      :string
#  screen_height    :integer
#  screen_width     :integer
#  country          :string
#  region           :string
#  city             :string
#  postal_code      :string
#  latitude         :decimal(, )
#  longitude        :decimal(, )
#  utm_source       :string
#  utm_medium       :string
#  utm_term         :string
#  utm_content      :string
#  utm_campaign     :string
#  started_at       :datetime
#

class Visit < ActiveRecord::Base
  has_many :events, class_name: "Ahoy::Event"
  belongs_to :user, optional: true

  scope :search_for, lambda { |search_term| where('utm_source ILIKE :t OR utm_medium ILIKE :t OR utm_term ILIKE :t  OR utm_content ILIKE :t  OR utm_campaign ILIKE :t ', t: '%' + search_term + '%').order(started_at: :desc) }
end
