require 'rails_helper'

RSpec.describe QuestionBanksController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/question_banks').to route_to('question_banks#index')
    end

    it 'routes to #new' do
      expect(get: '/question_banks/new').to route_to('question_banks#new')
    end

    it 'routes to #show' do
      expect(get: '/question_banks/1').to route_to('question_banks#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/question_banks/1/edit').to route_to('question_banks#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/question_banks').to route_to('question_banks#create')
    end

    it 'routes to #update' do
      expect(put: '/question_banks/1').to route_to('question_banks#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/question_banks/1').to route_to('question_banks#destroy', id: '1')
    end

  end
end
