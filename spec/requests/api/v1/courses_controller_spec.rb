# frozen_string_literal: true

require 'rails_helper'
require 'support/course_content'

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

  describe 'get /api/v1/courses/groups/:group_name' do
    include_context 'course_content' # support/course_content.rb

    context 'return all records' do
      before { get '/api/v1/courses/groups' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns courses json data' do
        body = JSON.parse(response.body)

        expect(body['groups'].size).to eq(2)
        expect(body['groups'].map { |j| j['id'] }).to include(group_1.id)
        expect(body['groups'].map { |j| j['name'] }).to include(group_1.name)
        expect(body['groups'].map { |j| j['name_url'] }).to include(group_1.name_url)
        expect(body['groups'].map { |j| j['description'] }).to include(group_1.description)
        expect(body['groups'].map { |j| j['short_description'] }).to include(group_1.short_description)
      end
    end

    context 'return group 1 data' do
      before { get "/api/v1/courses/groups/#{group_1.name_url}" }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns courses json data' do
        body = JSON.parse(response.body)

        expect(body['groups'].size).to eq(1)
        expect(body['groups'].map { |j| j['id'] }).to include(group_1.id)
        expect(body['groups'].map { |j| j['name'] }).to include(group_1.name)
        expect(body['groups'].map { |j| j['name_url'] }).to include(group_1.name_url)
        expect(body['groups'].map { |j| j['description'] }).to include(group_1.description)
        expect(body['groups'].map { |j| j['short_description'] }).to include(group_1.short_description)
      end
    end

    context 'return an not found message' do
      before { get '/api/v1/courses/groups/any_value' }

      it 'returns HTTP status 240400' do
        expect(response).to have_http_status 404
      end

      it 'returns empty data' do
        body = JSON.parse(response.body)

        expect(body['errors']).to eq('Group not found')
        expect([body.keys]).to contain_exactly(['errors'])
      end
    end
  end

  describe 'get /api/v1/courses/lessons/:group_name/:course_name' do
    include_context 'course_content' # support/course_content.rb

    context 'return all records' do
      before do
        get "/api/v1/courses/lessons/#{group_1.name_url}/#{course_1.name_url}"
      end

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'returns courses json data' do
        body         = JSON.parse(response.body)
        course       = body['course']
        section      = course['sections'].first
        lesson       = section['lessons'].first
        lesson_steps = lesson['steps']

        expect(course['id']).to eq(course_1.id)
        expect(course['name']).to eq(course_1.name)
        expect(course['name_url']).to eq(course_1.name_url)
        expect(course['sorting_order']).to eq(course_1.sorting_order)
        expect(course['description']).to eq(course_1.description)
        expect(course['release_date']).to eq(course_1.release_date)
        expect(course['level_id']).to eq(course_1.level_id)
        expect(course.keys).to eq(%w[id
                                     name
                                     name_url
                                     sorting_order
                                     description
                                     release_date
                                     level_id
                                     key_area_id
                                     key_area
                                     category_label
                                     icon_label
                                     unit_label
                                     sections])

        expect(section['id']).to eq(course_section_1.id)
        expect(section['name']).to eq(course_section_1.name)
        expect(section['url']).to eq(course_section_1.name_url)
        expect(section.keys).to eq(%w[id name url lessons])

        expect(lesson['id']).to eq(course_lesson_1.id)
        expect(lesson['name']).to eq(course_lesson_1.name)
        expect(lesson['url']).to eq(course_lesson_1.name_url)
        expect(lesson.keys).to eq(%w[id name url description free steps])

        expect(lesson_steps.size).to eq(6)
        expect(lesson_steps.map { |s| s['id'] }).to include(course_step_2.id)
        expect(lesson_steps.map { |s| s['name'] }).to include(course_step_2.name)
        expect(lesson_steps.map { |s| s['url'] }).to include(course_step_2.name_url)
        expect(lesson_steps.map { |s| s['kind'] }).to include(course_step_2.type_name)
        expect(lesson_steps.map { |s| s['video_data'] }).to include({ "dacast_id"=>course_video_1.dacast_id,
                                                                      "duration"=>course_video_1.duration,
                                                                      "vimeo_guid"=> course_video_1.vimeo_guid })
      end
    end

    describe 'not found errors' do
      context 'group not found message' do
        before { get "/api/v1/courses/lessons/any_group/any_value" }

        it 'returns HTTP status 404' do
          expect(response).to have_http_status 404
        end

        it 'returns empty data' do
          body = JSON.parse(response.body)

          expect(body['errors']).to eq('Group not found')
          expect([body.keys]).to contain_exactly(['errors'])
        end
      end

      context 'course not found message' do
        before { get "/api/v1/courses/lessons/#{group_1.name_url}/any_value" }

        it 'returns HTTP status 404' do
          expect(response).to have_http_status 404
        end

        it 'returns empty data' do
          body = JSON.parse(response.body)

          expect(body['errors']).to eq('Course not found')
          expect([body.keys]).to contain_exactly(['errors'])
        end
      end
    end
  end

  describe '#read_note_log' do
    let(:user_group)       { create(:student_user_group) }
    let(:student)          { create(:basic_student, :with_group, user_group: user_group) }
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
