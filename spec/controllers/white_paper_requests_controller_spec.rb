# == Schema Information
#
# Table name: white_paper_requests
#
#  id             :integer          not null, primary key
#  name           :string
#  email          :string
#  number         :string
#  company_name   :string
#  white_paper_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

describe WhitePaperRequestsController, type: :controller do

  let(:marketing_manager_user_group) { FactoryBot.create(:marketing_manager_user_group) }
  let(:marketing_manager_user) { FactoryBot.create(:marketing_manager_user, user_group_id: marketing_manager_user_group.id) }
  let!(:marketing_manager_student_access) { FactoryBot.create(:complimentary_student_access, user_id: marketing_manager_user.id) }

  let!(:white_paper_request_1) { FactoryBot.create(:white_paper_request) }
  let!(:white_paper_request_2) { FactoryBot.create(:white_paper_request) }
  let!(:valid_params) { FactoryBot.attributes_for(:white_paper_request) }

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('white_paper_requests', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see white_paper_request_1' do
        get :show, id: white_paper_request_1.id
        expect_show_success_with_model('white_paper_request', white_paper_request_1.id)
      end

      # optional - some other object
      it 'should see white_paper_request_2' do
        get :show, id: white_paper_request_2.id
        expect_show_success_with_model('white_paper_request', white_paper_request_2.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: white_paper_request_2.id
        expect_delete_success_with_model('white_paper_request', white_paper_requests_url)
      end
    end

  end

end
