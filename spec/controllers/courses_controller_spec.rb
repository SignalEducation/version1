require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe CoursesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:course_module_1) { FactoryGirl.create(:course_module) }
  let!(:qualification) { FactoryGirl.create(:qualification) }

  describe "GET show" do
    it "returns http success" do
      #get '/en/courses', institution_name_url: 'abc', qualification_name_url: 'abc', exam_level_name_url: 'abc', exam_section_name_url: 'abc', course_module_name_url: course_module_1.name_url
      get :show, id: nil, course_module_name_url: course_module_1.name_url,
          qualification_url: qualification.name_url
      expect_show_success_with_model(CourseModule, course_special_link(course_module_1))
    end
  end

end