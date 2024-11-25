# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:student_user_group) { create(:student_user_group ) }
  let!(:student_user)      { create(:student_user, user_group_id: student_user_group.id) }

  context 'Logged in as a student_user: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe 'GET show' do
      it 'should respond OK' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end
  end
end
