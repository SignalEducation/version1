require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe FooterPagesController, type: :controller do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let(:tutor_user_1) { FactoryBot.create(:tutor_user, user_group_id: tutor_user_group.id,
                                         subject_courses: [(subject_course_1)]) }

  let!(:tutor_student_access_1) { FactoryBot.create(:complimentary_student_access, user_id: tutor_user_1.id) }


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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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

  context 'Logged in as a valid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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

  context 'Logged in as a invalid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_trial_student)
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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

  context 'Logged in as a valid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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

  context 'Logged in as a invalid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_subscription_student)
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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

  context 'Logged in as a system_requirements_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(system_requirements_user)
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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

  context 'Logged in as a stripe_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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

  context 'Logged in as a user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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

  context 'Logged in as a developers_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(developers_user)
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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

  context 'Logged in as a user_group_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_group_manager_user)
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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
      it 'should render with 200' do
        get :profile, id: tutor_user_1.id
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
