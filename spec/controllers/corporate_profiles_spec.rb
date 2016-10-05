require 'rails_helper'
require 'support/users_and_groups_setup'

describe CorporateProfilesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:corporation_1) { FactoryGirl.create(:corporate_customer) }
  let!(:corporation_2) { FactoryGirl.create(:corporate_customer) }

  let!(:valid_params) { FactoryGirl.attributes_for(:corporate_student_user) }

  before(:each) do
    @request.host = "#{corporation_1.subdomain}.example.com/login"
    x = corporate_student_user
  end

  context 'Not logged in: ' do

    describe "GET 'show/1'" do
      it 'should redirect to sign_in' do
        get :show, id: 1
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end

    describe "GET 'new'" do
      xit 'should redirect to sign_in' do
        get :new
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end
    end

    describe "POST 'create'" do
      it 'should be successful and redirect to dashboard' do
        post :create, user: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(subscription_groups_url)
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_customer: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_customer: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_customer: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user, corporate_customer_id: corporation_1.id)
    end

    describe "GET 'show/1'" do
      it 'should see his corporate customer overview' do
        get :show, id: corporation_1.id
        expect_bounce_as_signed_in
      end

      it 'should not see other corporate customer overview' do
        get :show, id: corporation_2.id
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_customer: valid_params
        expect_bounce_as_signed_in
      end
    end
  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_customer: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_customer: valid_params
        expect_bounce_as_signed_in
      end
    end
  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_customer: valid_params
        expect_bounce_as_signed_in
      end
    end
  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'show/1'" do
      it 'should see corporation_1' do
        get :show, id: corporation_1.id
        expect_bounce_as_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, corporate_customer: valid_params
        expect_bounce_as_signed_in
      end

      it 'should report error for invalid params' do
        post :create, corporate_customer: {valid_params.keys.first => ''}
        expect_bounce_as_signed_in
      end
    end

  end

end
