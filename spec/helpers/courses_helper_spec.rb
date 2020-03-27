# frozen_string_literal: true

require 'rails_helper'

describe CoursesHelper do
  describe '#course_lesson_status' do
    let(:course_lesson) { create(:course_lesson) }

    context 'completed' do
      it 'completed class' do
        expect(course_lesson_status(course_lesson, true, [course_lesson.id])).to eq('completed')
      end
    end

    context 'incompleted' do
      it 'empty class' do
        expect(course_lesson_status(course_lesson, false, [course_lesson.id])).to eq('')
      end
    end
  end

  describe '#course_element_user_log_status' do
    context 'Quiz' do
      let(:cmeul) { build(:course_step_log, is_quiz: true, is_video: nil) }

      it 'started status' do
        cmeul.quiz_result = 'started'

        expect(course_element_user_log_status(cmeul)).to eq('started')
      end

      it 'passed status' do
        cmeul.quiz_result = 'passed'

        expect(course_element_user_log_status(cmeul)).to eq('passed')
      end

      it 'failed status' do
        cmeul.quiz_result = 'failed'

        expect(course_element_user_log_status(cmeul)).to eq('failed')
      end
    end

    context 'Other Course Module Element Types' do
      let(:cmeul) { build(:course_step_log, is_quiz: false, is_video: true) }

      it 'started status' do
        cmeul.element_completed = false

        expect(course_element_user_log_status(cmeul)).to eq('started')
      end

      it 'completed status' do
        cmeul.element_completed = true

        expect(course_element_user_log_status(cmeul)).to eq('completed')
      end
    end
  end
end
