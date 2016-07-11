# == Schema Information
#
# Table name: white_papers
#
#  id                       :integer          not null, primary key
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  sorting_order            :integer
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#  name_url                 :string
#  name                     :string
#

require 'rails_helper'

RSpec.describe "WhitePapers", type: :request do
  describe "GET /white_papers" do
    it "works! (now write some real specs)" do
      get white_papers_path
      expect(response).to have_http_status(200)
    end
  end
end
