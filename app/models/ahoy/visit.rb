# frozen_string_literal: true

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

class Ahoy::Visit < ApplicationRecord
  has_many :events, class_name: 'Ahoy::Event', dependent: :destroy
  has_one :subscription, foreign_key: 'ahoy_visit_id', inverse_of: :ahoy_visit
  belongs_to :user, optional: true

  scope :search_for, ->(search_term) { where('utm_source ILIKE :t OR utm_medium ILIKE :t OR utm_term ILIKE :t  OR utm_content ILIKE :t  OR utm_campaign ILIKE :t ', t: '%' + search_term + '%').order(started_at: :desc) }
  scope :all_in_order, -> { order(:started_at) }
end
