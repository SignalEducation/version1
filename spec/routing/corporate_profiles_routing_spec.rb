require 'rails_helper'

RSpec.describe CorporateProfilesController, type: :routing do
  describe 'routing' do

    let(:url)     { "http://corp.example.com" }

    it 'routes to #show' do
      expect(get: "#{url}/").to route_to('corporate_profiles#show')
    end

    it 'routes to #login' do
      expect(get: "#{url}/login").to route_to('corporate_profiles#login')
    end

    it 'routes to #new' do
      expect(get: '/corporate_profiles/new').to route_to('corporate_profiles#new')
    end

    it 'routes to #create' do
      expect(post: '/corporate_profiles/create').to route_to('corporate_profiles#create')
    end

  end
end
