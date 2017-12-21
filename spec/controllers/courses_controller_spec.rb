require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe CoursesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:subject_course) { FactoryGirl.create(:active_subject_course) }
  let!(:course_module_1) { FactoryGirl.create(:course_module, subject_course_id: subject_course.id) }
  let!(:course_module_element) { FactoryGirl.create(:course_module_element, course_module_id: course_module_1.id)}

  #let!(:course_module_element_user_log) { FactoryGirl.create(:course_module_element_user_log, course_module_element_id: course_module_element.id, course_module_id: course_module_1.id, user_id: student_user.id)}

  #let!(:valid_params) { course_module_element_user_log.attributes.merge({time_taken_in_seconds: (Time.now.to_i * -1)}) }

  ##TODO
  ## This needs a massive overhaul. No user_group distinction
  ## Will need to create proper SCUL-SET-CMEUL tree
  ##TODO

  describe 'GET show' do
    it 'returns http success' do
      get :show, subject_course_name_url: subject_course.name_url,
          course_module_name_url: course_module_1.name_url
      expect_bounce_as_not_signed_in
    end
  end

  describe 'POST create' do

    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    xit 'should report OK for valid params' do
      post :create, course_module_element_user_log: valid_params
      expect(response.status).to eq(200)
      expect(response).to render_template(:show)
    end

    #TODO need to build out cmeq and quiz answers an quiz attempts
    xit 'should report error for invalid params' do
      post :create, course_module_element_user_log: {valid_params.keys.first => ''}
      expect(response.status).to eq(302)
      expect(flash[:error]).to eq(I18n.t('controllers.courses.create.flash.error'))
    end
  end

end
