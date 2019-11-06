# frozen_string_literal: true

require 'rails_helper'

describe CbeQuestionsHelper do
  let(:question)        { build(:cbe_question) }
  let(:user_answers)    { build_list(:cbe_user_answer, 5, question: question) }

  describe '#user_answers_score' do
    it 'returns zero score' do
      user_answers.each { |r| r.content['correct'] = false }

      expect(user_answers_score(question, user_answers)).to be_zero
    end

    it 'returns the correct score' do
      user_answers.each { |r| r.content['correct'] = true }

      expect(user_answers_score(question, user_answers)).to eq(question.score)
    end
  end
end
