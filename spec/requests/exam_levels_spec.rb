require 'rails_helper'

RSpec.describe 'ExamLevels', type: :request do
  describe 'GET /exam_levels' do
    xit 'works! (now write some real specs)' do
      get exam_levels_path
      expect(response).to have_http_status(200)
    end
  end
end
