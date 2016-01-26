# == Schema Information
#
# Table name: question_banks
#
#  id                          :integer          not null, primary key
#  question_selection_strategy :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  subject_course_id           :integer
#  number_of_questions         :integer
#  name                        :string
#  active                      :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe QuestionBanksController, type: :routing do
  describe 'routing' do

    it 'routes to #new' do
      expect(get: '/question_banks/new').to route_to('question_banks#new')
    end

    it 'routes to #create' do
      expect(post: '/question_banks').to route_to('question_banks#create')
    end

    it 'routes to #destroy' do
      expect(delete: '/question_banks/1').to route_to('question_banks#destroy', id: '1')
    end

  end
end
