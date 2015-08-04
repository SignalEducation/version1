require 'rails_helper'

RSpec.describe StudentSignUpsController, type: :routing do
  describe 'routing' do

    xit 'routes to #show' do
      expect(get: '/student_sign_ups/abc123').to route_to('student_sign_ups#show', id: 'abc123')
    end

    xit 'routes to #show' do
      expect(get: '/personal_sign_up_complete/abc123').to route_to('student_sign_ups#show', id: 'abc123')
    end

    xit 'routes to #new' do
      expect(get: '/student_sign_up').to route_to('student_sign_ups#new')
    end

    xit 'routes to #new' do
      expect(get: '/student_sign_ups/new').to route_to('student_sign_ups#new')
    end

    xit 'routes to #create' do
      expect(post: '/student_sign_ups').to route_to('student_sign_ups#create')
    end

  end
end
