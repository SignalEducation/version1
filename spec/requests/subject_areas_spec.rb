require 'rails_helper'

RSpec.describe 'SubjectAreas', type: :request do
  describe 'GET /subject_areas' do
    xit 'works! (now write some real specs)' do
      get subject_areas_path
      expect(response).to have_http_status(200)
    end
  end
end
