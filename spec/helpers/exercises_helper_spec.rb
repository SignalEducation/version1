# frozen_string_literal: true

require 'rails_helper'

describe ExercisesHelper, type: :helper do
  let(:order)                     { create(:order) }
  let(:cbe)                       { create(:cbe) }
  let(:cbe_product)               { create(:product, cbe: cbe, product_type: 'cbe') }
  let(:correction_pack_product)   { create(:product, cbe: cbe, product_type: 'correction_pack', correction_pack_count: 3) }
  let(:mock_exam_product)         { create(:product, cbe: cbe, product_type: 'mock_exam', correction_pack_count: 3) }
  let!(:cbe_exercise)             { create(:exercise, product: cbe_product) }
  let!(:correction_pack_exercise) { create(:exercise, product: correction_pack_product) }
  let!(:mock_exam_exercise)       { create(:exercise, product: mock_exam_product) }
  let(:cbe_user_log)              { create(:cbe_user_log, cbe: cbe, exercise: cbe_exercise) }
  let(:questions)                 { create_list(:cbe_user_question, 5, user_log: cbe_user_log) }
  let(:answer)                    { create(:cbe_user_answer, cbe_user_question_id: question.id) }
  describe '#order_link' do
    context 'returns pending_exercise_message' do
      it 'Cbe product' do
        expect(pending_exercise_message(cbe_exercise)).to eq('Start your CBE session')
      end

      it 'Mock exam product' do
        expect(pending_exercise_message(mock_exam_exercise)).to eq('Start your mock exam')
      end

      it 'Correction pack product' do
        expect(pending_exercise_message(correction_pack_exercise)).to eq('Submit your questions & answers work for correction')
      end
    end
  end

  describe '#cbe_score' do
    it 'return total score from a cbe' do
      total_scores  = cbe_user_log.cbe.questions.map(&:score).sum
      student_score = cbe_user_log.score

      expect(cbe_score(cbe_user_log)).to eq("Total Score: #{student_score}/#{total_scores}")
    end
  end

  describe '#cbe_section_score' do
    it 'Cbe product' do
      total_scores  = questions.map { |q| q.cbe_question.score }.sum
      student_score = questions.map(&:score).sum

      expect(cbe_section_score(questions)).to eq("(#{student_score}/#{total_scores})")
    end
  end

  describe '#exercise_due_date' do
    describe 'finished exercises' do
      before do
        allow_any_instance_of(Exercise).to receive(:cbe_user_log).and_return(cbe_user_log)
        cbe_exercise.cbe_user_log.questions << questions
        cbe_user_log.update(status: 'finished')
      end

      it 'autocorrected due date exercise' do
        allow_any_instance_of(Cbe::Question).to receive(:kind).and_return('multiple_choice')
        expect(exercise_due_date(cbe_exercise)).to eq(cbe_exercise.submitted_on&.strftime('%d/%m/%y %H:%m'))
      end

      it 'not autocorrected due date exercise' do
        allow_any_instance_of(Cbe::Question).to receive(:kind).and_return('open')
        expect(exercise_due_date(cbe_exercise)).to eq((cbe_exercise.submitted_on + 3.days)&.strftime('%d/%m/%y %H:%m'))
      end
    end

    describe 'unfinished exercises' do
      it 'due date exercise' do
        expect(exercise_due_date(cbe_exercise)).to eq('-')
      end
    end
  end
end
