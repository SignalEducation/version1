# == Schema Information
#
# Table name: course_module_jumbo_quizzes
#
#  id                                :integer          not null, primary key
#  course_module_id                  :integer
#  name                              :string
#  minimum_question_count_per_quiz   :integer
#  maximum_question_count_per_quiz   :integer
#  total_number_of_questions         :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  name_url                          :string
#  best_possible_score_first_attempt :integer          default(0)
#  best_possible_score_retry         :integer          default(0)
#  destroyed_at                      :datetime
#  active                            :boolean          default(FALSE), not null
#

require 'rails_helper'

RSpec.describe CourseModuleJumboQuizzesController, type: :routing do
  describe 'routing' do

    it 'routes to #new' do
      expect(get: '/course_module_jumbo_quizzes/new').to route_to('course_module_jumbo_quizzes#new')
    end

    it 'routes to #edit' do
      expect(get: '/course_module_jumbo_quizzes/1/edit').to route_to('course_module_jumbo_quizzes#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/course_module_jumbo_quizzes').to route_to('course_module_jumbo_quizzes#create')
    end

    it 'routes to #update' do
      expect(put: '/course_module_jumbo_quizzes/1').to route_to('course_module_jumbo_quizzes#update', id: '1')
    end

  end
end
