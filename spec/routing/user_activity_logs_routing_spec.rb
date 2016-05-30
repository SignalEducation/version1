# == Schema Information
#
# Table name: user_activity_logs
#
#  id                               :integer          not null, primary key
#  user_id                          :integer
#  session_guid                     :string
#  signed_in                        :boolean          default(FALSE), not null
#  original_uri                     :text
#  controller_name                  :string
#  action_name                      :string
#  params                           :text
#  alert_level                      :integer          default(0)
#  created_at                       :datetime
#  updated_at                       :datetime
#  ip_address                       :string
#  browser                          :string
#  operating_system                 :string
#  phone                            :boolean          default(FALSE), not null
#  tablet                           :boolean          default(FALSE), not null
#  computer                         :boolean          default(FALSE), not null
#  guid                             :string
#  ip_address_id                    :integer
#  browser_version                  :string
#  raw_user_agent                   :string
#  first_session_landing_page       :text
#  latest_session_landing_page      :text
#  post_sign_up_redirect_url        :string
#  marketing_token_id               :integer
#  marketing_token_cookie_issued_at :datetime
#

require 'rails_helper'

RSpec.describe UserActivityLogsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/user_activity_logs').to route_to('user_activity_logs#index')
    end

    it 'routes to #new' do
      expect(get: '/user_activity_logs/new').to route_to('user_activity_logs#new')
    end

    it 'routes to #show' do
      expect(get: '/user_activity_logs/1').to route_to('user_activity_logs#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/user_activity_logs/1/edit').to route_to('user_activity_logs#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/user_activity_logs').to route_to('user_activity_logs#create')
    end

    it 'routes to #update' do
      expect(put: '/user_activity_logs/1').to route_to('user_activity_logs#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/user_activity_logs/1').to route_to('user_activity_logs#destroy', id: '1')
    end

  end
end
