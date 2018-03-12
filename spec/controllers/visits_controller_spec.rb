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

require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe VisitsController, :type => :controller do

  include_context 'users_and_groups_setup'

end
