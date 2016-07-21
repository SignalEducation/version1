# == Schema Information
#
# Table name: corporate_customers
#
#  id                   :integer          not null, primary key
#  organisation_name    :string
#  address              :text
#  country_id           :integer
#  payments_by_card     :boolean          default(FALSE), not null
#  stripe_customer_guid :string
#  created_at           :datetime
#  updated_at           :datetime
#  logo_file_name       :string
#  logo_content_type    :string
#  logo_file_size       :integer
#  logo_updated_at      :datetime
#  subdomain            :string
#  user_name            :string
#  passcode             :string
#  external_url         :string
#  footer_border_colour :string           default("#EFF3F6")
#  corporate_email      :string
#  external_logo_link   :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe CorporateCustomersController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/corporate_customers').to route_to('corporate_customers#index')
    end

    it 'routes to #new' do
      expect(get: '/corporate_customers/new').to route_to('corporate_customers#new')
    end

    it 'routes to #show' do
      expect(get: '/corporate_customers/1').to route_to('corporate_customers#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/corporate_customers/1/edit').to route_to('corporate_customers#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/corporate_customers').to route_to('corporate_customers#create')
    end

    it 'routes to #update' do
      expect(put: '/corporate_customers/1').to route_to('corporate_customers#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/corporate_customers/1').to route_to('corporate_customers#destroy', id: '1')
    end

  end
end
