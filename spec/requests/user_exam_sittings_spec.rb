# == Schema Information
#
# Table name: user_exam_sittings
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  exam_sitting_id   :integer
#  subject_course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe "UserExamSittings", type: :request do
  describe "GET /user_exam_sittings" do
    it "works! (now write some real specs)" do
      get user_exam_sittings_path
      expect(response).to have_http_status(200)
    end
  end
end
