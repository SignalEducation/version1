require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'User navigating through the library:' do

  include_context 'users_and_groups_setup'

  let!(:static_page) { FactoryGirl.create(:landing_page) }
  let!(:subject_area_1) { FactoryGirl.create(:active_subject_area) }
  let!(:subject_area_2) { FactoryGirl.create(:active_subject_area) }
  let!(:institution_1) { FactoryGirl.create(:active_institution, subject_area_id: subject_area_1.id) }
  let!(:institution_2) { FactoryGirl.create(:active_institution, subject_area_id: subject_area_2.id) }
  let!(:qualification_1) { FactoryGirl.create(:active_qualification, institution_id: institution_1.id) }
  let!(:qualification_2) { FactoryGirl.create(:active_qualification, institution_id: institution_2.id) }
  let!(:exam_level_1) { FactoryGirl.create(:active_exam_level_with_exam_sections, qualification_id: qualification_1.id) }
  let!(:exam_level_2) { FactoryGirl.create(:active_exam_level_without_exam_sections, qualification_id: qualification_2.id) }
  let!(:exam_section_1) { FactoryGirl.create(:active_exam_section, exam_level_id: exam_level_1.id) }
  let!(:course_module_1) { FactoryGirl.create(:active_course_module, qualification_id: qualification_1.id, exam_section_id: exam_section_1.id) }
  let!(:course_module_2) { FactoryGirl.create(:active_course_module, qualification_id: qualification_2.id, exam_level_id: exam_level_2.id) }
  let!(:course_module_element_1) { FactoryGirl.create(:cme_video, course_module_id: course_module_1.id) }
  let!(:course_module_element_2) { FactoryGirl.create(:cme_quiz, course_module_id: course_module_2.id) }
  let!(:course_module_element_video_1) { FactoryGirl.create(:course_module_element_video, course_module_element_id: course_module_element_1.id) }
  let!(:course_module_element_quiz_1) { FactoryGirl.create(:course_module_element_quiz, course_module_element_id: course_module_element_2.id) }


  before(:each) do
    activate_authlogic
  end

  scenario 'user signs in then navigates down hierarchy to first cme', js: true  do
    visit root_path
    click_link 'Library'
    binding.pry
  end

end