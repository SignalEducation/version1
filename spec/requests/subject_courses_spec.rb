require 'rails_helper'

RSpec.describe "SubjectCourses", type: :request do
  describe "GET /subject_courses" do
    it "works! (now write some real specs)" do
      get subject_courses_path
      expect(response).to have_http_status(200)
    end
  end
end
