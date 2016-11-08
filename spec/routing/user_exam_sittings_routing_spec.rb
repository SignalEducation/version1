# == Schema Information
#
# Table name: user_exam_sittings
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  exam_sitting_id   :integer
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe UserExamSittingsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/user_exam_sittings').to route_to('user_exam_sittings#index')
    end

    it 'routes to #new' do
      expect(get: '/user_exam_sittings/new').to route_to('user_exam_sittings#new')
    end

    it 'routes to #show' do
      expect(get: '/user_exam_sittings/1').to route_to('user_exam_sittings#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/user_exam_sittings/1/edit').to route_to('user_exam_sittings#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/user_exam_sittings').to route_to('user_exam_sittings#create')
    end

    it 'routes to #update' do
      expect(put: '/user_exam_sittings/1').to route_to('user_exam_sittings#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/user_exam_sittings/1').to route_to('user_exam_sittings#destroy', id: '1')
    end

  end
end
