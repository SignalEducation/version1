# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CoursesController', type: :request do
  describe 'get /api/v1/courses' do
    context 'return all records' do
      let!(:courses) { create_list(:active_course, 5) }

      before { get '/api/v1/courses' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns courses json data' do
        body = JSON.parse(response.body)

        expect(body.size).to eq(5)
        expect(body.map { |j| j['value'] }).to match_array(courses.pluck(:id))
        expect(body.map { |j| j['text'] }).to match_array(courses.pluck(:name))
      end
    end

    context 'return an empty record' do
      before { get '/api/v1/courses' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)
        expect(body).to be_empty
      end
    end
  end
  describe '#read_note_log' do
    let(:user_group)    { create(:student_user_group) }
    let(:student)       { create(:basic_student, :with_group, user_group: user_group) }
    let!(:course)          { create(:course) }
    let!(:course_log)      { create(:course_log, course: course, user: student) }
    let!(:course_section)  { create(:course_section, course: course) }
    let!(:course_lesson)   { create(:course_lesson, course_section: course_section, course: course) }
    let!(:course_step)     { create(:course_step, :video_step, course_lesson: course_lesson, sorting_order: 1) }
    let!(:course_step_log) { create(:course_step_log, id: 1, course_step: course_step, course_id: course.id, course_section_id: course_section.id, course_lesson_id: course_lesson.id, course_log_id: course_log.id) }

    context 'return status OK' do
      it 'should report OK for element_completed true' do
        post "/api/v1/courses/#{course.id}/read_note_log", params: { step_log_id: course_step_log.id }

        body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(body['element_completed']).to be_truthy
      end
    end

    context 'return status Error' do
      before do
        allow_any_instance_of(CourseStepLog).to receive(:update).and_return(false)
      end
      it 'should be nil if element_completed false' do
        post "/api/v1/courses/#{course.id}/read_note_log", params: { step_log_id: course_step_log.id }

        body = JSON.parse(response.body)

        expect(response.status).to eq(500)
        expect(body['element_completed']).to be_nil
      end
    end

    context 'return status Error on Rescue' do
      before do
        allow(CourseStepLog).to(receive(:find).and_raise(ActiveRecord::RecordNotFound))
      end
      it 'should be nil on active record error' do
        post "/api/v1/courses/#{course.id}/read_note_log", params: { step_log_id: course_step_log.id }

        body = JSON.parse(response.body)

        expect(response.status).to eq(500)
        expect(body['element_completed']).to be_nil
      end
    end
  end
end
