require 'rails_helper'
require 'support/users_and_groups_setup'

describe ContentActivationsController, type: :controller do

  let!(:group) { FactoryBot.create(:group) }
  let!(:exam_body) { FactoryBot.create(:exam_body) }
  let!(:subject_course)  { FactoryBot.create(:active_subject_course, group_id: group.id, exam_body_id: exam_body.id) }
  let!(:course_section) { FactoryBot.create(:course_section,
                                              subject_course: subject_course) }
  let!(:course_module) { FactoryBot.create(:active_course_module,
                                             course_section: course_section,
                                             subject_course: subject_course) }
  let!(:course_module_element) { FactoryBot.create(:cme_video,
                                                       course_module: course_module) }

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
        post :create, params: {id: course_module_element.id, type: 'CourseModuleElement', datetime: '24/10/2020 00:00:00'}
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(subject_course_url(subject_course.id))
      end

    end

  end
end
