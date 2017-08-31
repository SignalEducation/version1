require 'rails_helper'
require 'support/users_and_groups_setup'

describe FooterPagesController, type: :controller do

  include_context 'users_and_groups_setup'


  context 'Not logged in: ' do

    describe "GET 'privacy_policy'" do
      it 'should render with 200' do
        get :privacy_policy
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:privacy_policy)
      end
    end

    describe "GET 'acca_info'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'contact'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)

      end
    end

    describe "Get 'terms_and_conditions'" do
      it 'should render with 200' do
        get :terms_and_conditions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:terms_and_conditions)

      end
    end

    describe "Get 'profile'" do
      #Fails dus to redirect since the tutor has no active courses. Build test data for HABTM
      xit 'should render with 200' do
        get :profile, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile)

      end
    end

    describe "Get 'profile_index'" do
      it 'should render with 200' do
        get :profile_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'privacy_policy'" do
      it 'should render with 200' do
        get :privacy_policy
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:privacy_policy)
      end
    end

    describe "GET 'acca_info'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'contact'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)

      end
    end

    describe "Get 'terms_and_conditions'" do
      it 'should render with 200' do
        get :terms_and_conditions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:terms_and_conditions)

      end
    end

    describe "Get 'profile'" do
      #Fails dus to redirect since the tutor has no active courses. Build test data for HABTM
      xit 'should render with 200' do
        get :profile, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile)

      end
    end

    describe "Get 'profile_index'" do
      it 'should render with 200' do
        get :profile_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'privacy_policy'" do
      it 'should render with 200' do
        get :privacy_policy
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:privacy_policy)
      end
    end

    describe "GET 'acca_info'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'contact'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)

      end
    end

    describe "Get 'terms_and_conditions'" do
      it 'should render with 200' do
        get :terms_and_conditions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:terms_and_conditions)

      end
    end

    describe "Get 'profile'" do
      #Fails dus to redirect since the tutor has no active courses. Build test data for HABTM
      xit 'should render with 200' do
        get :profile, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile)

      end
    end

    describe "Get 'profile_index'" do
      it 'should render with 200' do
        get :profile_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'privacy_policy'" do
      it 'should render with 200' do
        get :privacy_policy
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:privacy_policy)
      end
    end

    describe "GET 'acca_info'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'contact'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)

      end
    end

    describe "Get 'terms_and_conditions'" do
      it 'should render with 200' do
        get :terms_and_conditions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:terms_and_conditions)

      end
    end

    describe "Get 'profile'" do
      #Fails dus to redirect since the tutor has no active courses. Build test data for HABTM
      xit 'should render with 200' do
        get :profile, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile)

      end
    end

    describe "Get 'profile_index'" do
      it 'should render with 200' do
        get :profile_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'privacy_policy'" do
      it 'should render with 200' do
        get :privacy_policy
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:privacy_policy)
      end
    end

    describe "GET 'acca_info'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'contact'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)

      end
    end

    describe "Get 'terms_and_conditions'" do
      it 'should render with 200' do
        get :terms_and_conditions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:terms_and_conditions)

      end
    end

    describe "Get 'profile'" do
      #Fails dus to redirect since the tutor has no active courses. Build test data for HABTM
      xit 'should render with 200' do
        get :profile, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile)

      end
    end

    describe "Get 'profile_index'" do
      it 'should render with 200' do
        get :profile_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'privacy_policy'" do
      it 'should render with 200' do
        get :privacy_policy
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:privacy_policy)
      end
    end

    describe "GET 'acca_info'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'contact'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)

      end
    end

    describe "Get 'terms_and_conditions'" do
      it 'should render with 200' do
        get :terms_and_conditions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:terms_and_conditions)

      end
    end

    describe "Get 'profile'" do
      #Fails dus to redirect since the tutor has no active courses. Build test data for HABTM
      xit 'should render with 200' do
        get :profile, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile)

      end
    end

    describe "Get 'profile_index'" do
      it 'should render with 200' do
        get :profile_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'privacy_policy'" do
      it 'should render with 200' do
        get :privacy_policy
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:privacy_policy)
      end
    end

    describe "GET 'acca_info'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'contact'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)

      end
    end

    describe "Get 'terms_and_conditions'" do
      it 'should render with 200' do
        get :terms_and_conditions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:terms_and_conditions)

      end
    end

    describe "Get 'profile'" do
      #Fails dus to redirect since the tutor has no active courses. Build test data for HABTM
      xit 'should render with 200' do
        get :profile, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile)

      end
    end

    describe "Get 'profile_index'" do
      it 'should render with 200' do
        get :profile_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'privacy_policy'" do
      it 'should render with 200' do
        get :privacy_policy
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:privacy_policy)
      end
    end

    describe "GET 'acca_info'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'contact'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)

      end
    end

    describe "Get 'terms_and_conditions'" do
      it 'should render with 200' do
        get :terms_and_conditions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:terms_and_conditions)

      end
    end

    describe "Get 'profile'" do
      #Fails dus to redirect since the tutor has no active courses. Build test data for HABTM
      xit 'should render with 200' do
        get :profile, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile)

      end
    end

    describe "Get 'profile_index'" do
      it 'should render with 200' do
        get :profile_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'privacy_policy'" do
      it 'should render with 200' do
        get :privacy_policy
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:privacy_policy)
      end
    end

    describe "GET 'acca_info'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'contact'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)

      end
    end

    describe "Get 'terms_and_conditions'" do
      it 'should render with 200' do
        get :terms_and_conditions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:terms_and_conditions)

      end
    end

    describe "Get 'profile'" do
      #Fails dus to redirect since the tutor has no active courses. Build test data for HABTM
      xit 'should render with 200' do
        get :profile, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile)

      end
    end

    describe "Get 'profile_index'" do
      it 'should render with 200' do
        get :profile_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

  end

end
