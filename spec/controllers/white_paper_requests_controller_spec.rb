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
require 'support/users_and_groups_setup'

describe WhitePaperRequestsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:white_paper_request_1) { FactoryGirl.create(:white_paper_request) }
  let!(:white_paper_request_2) { FactoryGirl.create(:white_paper_request) }
  let!(:valid_params) { FactoryGirl.attributes_for(:white_paper_request) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to sign_in' do
        get :show, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see white_paper_request_1' do
        get :show, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see white_paper_request_2' do
        get :show, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see white_paper_request_1' do
        get :show, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see white_paper_request_2' do
        get :show, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see white_paper_request_1' do
        get :show, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see white_paper_request_2' do
        get :show, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see white_paper_request_1' do
        get :show, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see white_paper_request_2' do
        get :show, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see white_paper_request_1' do
        get :show, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see white_paper_request_2' do
        get :show, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see white_paper_request_1' do
        get :show, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see white_paper_request_2' do
        get :show, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see white_paper_request_1' do
        get :show, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see white_paper_request_2' do
        get :show, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: white_paper_request_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: white_paper_request_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
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
