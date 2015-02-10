require 'rails_helper'

RSpec.describe Api::UserActivitiesController, type: :routing do

  it 'routes to #create' do
    expect(post: '/api/user_activities').to route_to('api/user_activities#create')
  end

end
