# == Schema Information
#
# Table name: subject_course_categories
#
#  id           :integer          not null, primary key
#  name         :string
#  payment_type :string
#  active       :boolean          default(FALSE)
#  subdomain    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe "SubjectCourseCategories", type: :request do
  describe "GET /subject_course_categories" do
    it "works! (now write some real specs)" do
      get subject_course_categories_path
      expect(response).to have_http_status(200)
    end
  end
end
