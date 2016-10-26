# == Schema Information
#
# Table name: exam_sittings
#
#  id                :integer          not null, primary key
#  name              :string
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe "ExamSittings", type: :request do
  describe "GET /exam_sittings" do
    it "works! (now write some real specs)" do
      get exam_sittings_path
      expect(response).to have_http_status(200)
    end
  end
end
