# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string
#  hints                         :text
#  created_at                    :datetime
#  updated_at                    :datetime
#  destroyed_at                  :datetime
#  subject_course_id             :integer
#

require 'rails_helper'

RSpec.describe QuizQuestionsController, type: :routing do
  describe 'routing' do

    it 'routes to #new' do
      expect(get: '/quiz_questions/new').to route_to('quiz_questions#new')
    end

    it 'routes to #show' do
      expect(get: '/quiz_questions/1').to route_to('quiz_questions#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/quiz_questions/1/edit').to route_to('quiz_questions#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/quiz_questions').to route_to('quiz_questions#create')
    end

    it 'routes to #update' do
      expect(put: '/quiz_questions/1').to route_to('quiz_questions#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/quiz_questions/1').to route_to('quiz_questions#destroy', id: '1')
    end

  end
end
