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
  let!(:course_module_element_user_log) { FactoryGirl.create(:course_module_element_user_log, course_module_element_id: course_module_element.id, course_module_id: course_module_1.id)}
  let!(:valid_params) { course_module_element_user_log.attributes.merge({time_taken_in_seconds: (Time.now.to_i * -1)}) }

  describe 'GET show' do
    it 'returns http success' do
      get :show, id: 1, course_module_name_url: course_module_1.name_url,
          qualification_url: qualification.name_url,
          exam_level_url: exam_level.name_url
      expect_show_success_with_model('course_module', course_module_1.id)
    end
  end

  describe 'POST create' do
    it 'should report OK for valid params' do
      post :create, course_module_element_user_log: valid_params
      expect(response.status).to eq(200)
      expect(response).to render_template(:show)
    end

    it 'should report error for invalid params' do
      post :create, course_module_element_user_log: {valid_params.keys.first => ''}
      expect(response.status).to eq(302)
      expect(flash[:error]).to eq(I18n.t('controllers.courses.create.flash.error'))
    end
  end

end
