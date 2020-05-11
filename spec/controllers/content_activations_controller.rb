require 'rails_helper'
require 'support/users_and_groups_setup'

describe ContentActivationsController, type: :controller do

  let!(:group) { FactoryBot.create(:group) }
  let!(:exam_body) { FactoryBot.create(:exam_body) }
  let!(:course)  { FactoryBot.create(:active_course, group_id: group.id, exam_body_id: exam_body.id) }
  let!(:course_section) { FactoryBot.create(:course_section,
                                              course: course) }
  let!(:course_lesson) { FactoryBot.create(:active_course_lesson,
                                             course_section: course_section,
                                             course: course) }
  let!(:course_step) { FactoryBot.create(:video_step,
                                                       course_lesson: course_lesson) }

  include_context 'users_and_groups_setup'


  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: {id: course_step.id, type: 'CourseStep', datetime: '24/10/2020 00:00:00'}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(course_url(course.id))
      end

    end

  end
end
