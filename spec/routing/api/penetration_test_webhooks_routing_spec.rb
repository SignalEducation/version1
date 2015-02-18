require 'rails_helper'

RSpec.describe Api::PenetrationTestWebhooksController, type: :routing do

  it 'routes to #test_starting' do
    expect(get: '/api/penetration_test_start').to route_to('api/penetration_test_webhooks#test_starting')
  end

  it 'routes to #test_complete' do
    expect(get: '/api/penetration_test_finish').to route_to('api/penetration_test_webhooks#test_complete')
  end

end
