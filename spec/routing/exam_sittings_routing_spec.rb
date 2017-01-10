# == Schema Information
#
# Table name: exam_sittings
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  exam_body_id      :integer
#

require 'rails_helper'

RSpec.describe ExamSittingsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/exam_sittings').to route_to('exam_sittings#index')
    end

    it 'routes to #new' do
      expect(get: '/exam_sittings/new').to route_to('exam_sittings#new')
    end

    it 'routes to #show' do
      expect(get: '/exam_sittings/1').to route_to('exam_sittings#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/exam_sittings/1/edit').to route_to('exam_sittings#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/exam_sittings').to route_to('exam_sittings#create')
    end

    it 'routes to #update' do
      expect(put: '/exam_sittings/1').to route_to('exam_sittings#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/exam_sittings/1').to route_to('exam_sittings#destroy', id: '1')
    end

  end
end
