# frozen_string_literal: true

require 'rails_helper'

describe CbeQuestionsHelper do
  let(:exercise_cbe) { create(:exercise) }
  let(:cbe)          { create(:cbe) }
  let(:cbe_user_log) { create(:cbe_user_log, cbe: cbe, exercise: exercise_cbe) }
  let!(:question)    { create(:cbe_user_question, user_log: cbe_user_log) }

  describe '#question_title' do
    it 'return correct stylized question title' do
      question.correct = true
      title = question_title(question)

      expect(title).to include('text-green')
      expect(title).to include(question.cbe_question.sorting_order.to_s)
      expect(title).to include(question.cbe_question.kind.humanize)
      expect(title).to include(question.cbe_question.score.to_s)
    end

    it 'return incorrect stylized question title' do
      question.correct = false
      title = question_title(question)

      expect(title).to include('text-red')
    end

    it 'return not corrected stylized question title' do
      question.correct = nil
      title = question_title(question)

      expect(title).to include('text-yellow')
    end
  end

  describe '#question_corrected_link' do
    it 'return question link' do
      button = question_corrected_link(question)

      expect(button).to include(question.cbe_question.kind.humanize)
    end
  end

  describe '#render_admin_answers' do
    it 'render a specific open_answer partial' do
      question.cbe_question.kind = Cbe::Question.kinds[:open]
      partial = render_admin_answers(question)

      expect(partial).to include('Educator Section')
    end

    it 'render a specific single_answer partial' do
      question.cbe_question.kind = Cbe::Question.kinds[:fill_in_the_blank]
      partial = render_admin_answers(question)

      expect(partial).to include(raw(question.answers.first.content['text']))
    end

    it 'render a specific multiple_answers partial' do
      question.cbe_question.kind = Cbe::Question.kinds[:multiple_choice]
      partial = render_admin_answers(question)

      expect(partial).to include(raw(question.answers.sample.content['text']))
    end
  end
end
