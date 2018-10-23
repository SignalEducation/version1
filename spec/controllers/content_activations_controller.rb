require 'rails_helper'
require 'support/course_content'

describe ContentActivationsController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:content_management_user_student_access) { FactoryBot.create(:complimentary_student_access, user_id: content_management_user.id) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course, group_id: 1, exam_body_id: 1) }
  let!(:subject_course_2)  { FactoryBot.create(:active_subject_course, group_id: 1, computer_based: true, exam_body_id: 1) }
  include_context 'course_content'

  let!(:valid_params) { {id: course_module_element_1_2.id, type: 'CourseModuleElement', datetime: '24/10/2018 00:00:00'} }
  #"id"=>"100", "type"=>"CourseModuleElement", "datetime"=>"24/10/2018 00:00:00",

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
        post :create, valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(subject_course_url(subject_course_1.id))
      end

    end

  end
end
