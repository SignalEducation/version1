# == Schema Information
#
# Table name: exam_bodies
#
#  id         :integer          not null, primary key
#  name       :string
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe ExamBodiesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/exam_bodies').to route_to('exam_bodies#index')
    end

    it 'routes to #new' do
      expect(get: '/exam_bodies/new').to route_to('exam_bodies#new')
    end

    it 'routes to #show' do
      expect(get: '/exam_bodies/1').to route_to('exam_bodies#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/exam_bodies/1/edit').to route_to('exam_bodies#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/exam_bodies').to route_to('exam_bodies#create')
    end

    it 'routes to #update' do
      expect(put: '/exam_bodies/1').to route_to('exam_bodies#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/exam_bodies/1').to route_to('exam_bodies#destroy', id: '1')
    end

  end
end
