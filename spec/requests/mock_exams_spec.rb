# == Schema Information
#
# Table name: mock_exams
#
#  id                :integer          not null, primary key
#  subject_course_id :integer
#  product_id        :integer
#  name              :string
#  sorting_order     :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#

require 'rails_helper'

RSpec.describe "MockExams", type: :request do
  describe "GET /mock_exams" do
    it "works! (now write some real specs)" do
      get mock_exams_path
      expect(response).to have_http_status(200)
    end
  end
end
