require 'rails_helper'

describe RoutesController, type: :controller do

  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:student_user) { FactoryBot.create(:student_user, user_group_id: student_user_group.id) }

  context 'Not logged in: ' do

    describe "GET 'root'" do
      it 'should redirect to home_page#show' do
        get :root
        expect(response.status).to eq(302)
      end
    end

  end

  context 'Logged in as a student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "GET 'root'" do
      it 'should redirect to dashboard#index' do
        get :root
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

  end

end
