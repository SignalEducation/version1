# == Schema Information
#
# Table name: tutor_applications
#
#  id          :integer          not null, primary key
#  first_name  :string
#  last_name   :string
#  email       :string
#  info        :text
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe TutorApplicationsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/tutor_applications').to route_to('tutor_applications#index')
    end

    it 'routes to #new' do
      expect(get: '/tutor_applications/new').to route_to('tutor_applications#new')
    end

    it 'routes to #show' do
      expect(get: '/tutor_applications/1').to route_to('tutor_applications#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/tutor_applications/1/edit').to route_to('tutor_applications#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/tutor_applications').to route_to('tutor_applications#create')
    end

    it 'routes to #update' do
      expect(put: '/tutor_applications/1').to route_to('tutor_applications#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/tutor_applications/1').to route_to('tutor_applications#destroy', id: '1')
    end

  end
end
