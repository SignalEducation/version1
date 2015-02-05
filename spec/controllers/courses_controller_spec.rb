require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe CoursesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:subject_area) { FactoryGirl.create(:subject_area)}
  let!(:institution) { FactoryGirl.create(:institution, subject_area_id: subject_area.id) }
  let!(:qualification) { FactoryGirl.create(:qualification, institution_id: institution.id) }
  let!(:exam_level) { FactoryGirl.create(:exam_level, qualification_id: qualification.id) }
  let!(:course_module_1) { FactoryGirl.create(:course_module, qualification_id: qualification.id, exam_level_id: exam_level.id, institution_id: institution.id) }
  let!(:course_module_element) { FactoryGirl.create(:course_module_element)}


  let!(:course_module_element_user_log) { FactoryGirl.create(:course_module_element_user_log)}
  let!(:valid_params) {FactoryGirl.attributes_for(:course_module_1, course_module_element_user_log_id: course_module_element_user_log.id)}

  describe "GET show" do
    it 'returns http success' do
      get :show, id: 1, course_module_name_url: course_module_1.name_url,
          qualification_url: qualification.name_url
      expect_show_success_with_model('course_module', course_module_1.id)
    end
  end


  describe "POST create" do
    it 'should report OK for valid params' do
      post :create, course_module_1: valid_params
      expect_create_success_with_model('course_module', course_modules_url)
    end

    it 'should report error for invalid params' do
      post :create, course_module_1: {valid_params.keys.first => ''}
      expect_create_error_with_model('course_module')
    end
  end

end