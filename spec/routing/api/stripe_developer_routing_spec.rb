require 'rails_helper'

RSpec.describe Api::StripeDevController, type: :routing do

  it 'routes to #create' do
    expect(post: '/api/stripe_dev/dan').to route_to('api/stripe_dev#create', dev_name: 'dan')
  end

end
