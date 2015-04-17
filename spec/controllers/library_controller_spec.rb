
require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

RSpec.describe LibraryController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  context 'Not logged in' do
    describe "GET 'show'" do
      it 'returns http success' do
        get :show
        expect(response).to have_http_status(:success)
      end
    end
  end

end
