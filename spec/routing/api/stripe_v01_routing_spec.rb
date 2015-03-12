require 'rails_helper'

RSpec.describe Api::StripeV01Controller, type: :routing do

  it 'routes to #create' do
    expect(post: '/api/stripe_v01').to route_to('api/stripe_v01#create')
  end

end
