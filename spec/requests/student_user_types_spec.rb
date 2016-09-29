# == Schema Information
#
# Table name: student_user_types
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :text
#  subscription  :boolean          default(FALSE)
#  product_order :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe "StudentUserTypes", type: :request do
  describe "GET /student_user_types" do
    it "works! (now write some real specs)" do
      get student_user_types_path
      expect(response).to have_http_status(200)
    end
  end
end
