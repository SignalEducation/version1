# frozen_string_literal: true

require 'rails_helper'

describe CbeQuestionsHelper, type: :helper do
  let(:exercise_cbe) { create(:exercise) }
  let(:cbe)          { create(:cbe) }
  let(:cbe_user_log) { create(:cbe_user_log, cbe: cbe, exercise: exercise_cbe) }
  let!(:question)    { create(:cbe_user_question, user_log: cbe_user_log) }
  let!(:answer)      { create(:cbe_user_answer, cbe_user_question_id: question.id) }

  describe '#question_title_class' do
    it 'return correct stylized question title class' do
      question.correct = true

      expect(question_title_class(question)).to include('glyphicon-ok')
    end

    it 'return incorrect stylized question title' do
      question.correct = false

      expect(question_title_class(question)).to include('glyphicon-remove')
    end

    it 'return not corrected stylized question title' do
      question.correct = nil

      expect(question_title_class(question)).to include('glyphicon-pencil')
    end

    it 'return not answered stylized question title' do
      expect(question_title_class(nil)).to include('glyphicon-exclamation')
    end
  end

  describe '#question_answer' do
    it 'return correct stylized question answer class' do
      answer.content['correct'] = true
      question_answer = question_answer(answer)

      expect(question_answer).to include('glyphicon-ok')
    end

    it 'return incorrect stylized question answer class' do
      answer.content['correct'] = false
      question_answer = question_answer(answer)

      expect(question_answer).to include('glyphicon-remove')
    end

    it 'return not corrected stylized question answer class' do
      answer.content['correct'] = nil
      question_answer = question_answer(answer)

      expect(question_answer).not_to include('glyphicon-ok')
      expect(question_answer).not_to include('glyphicon-remove')
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

      expect(partial).to include('Question Score & Comment')
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
