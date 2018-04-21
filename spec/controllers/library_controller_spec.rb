
require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'
require 'support/course_content'

RSpec.describe LibraryController, type: :controller do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'
  include_context 'course_content'


  let!(:mock_exam_1) { FactoryBot.create(:mock_exam) }
  let!(:product_1) { FactoryBot.create(:product, mock_exam_id: mock_exam_1.id, currency_id: gbp.id) }

  context 'Not logged in: ' do

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

  end

  context 'Logged in as a valid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a invalid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_trial_student)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a valid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a invalid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_subscription_student)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a system_requirements_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(system_requirements_user)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a stripe_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a developers_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(developers_user)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a user_group_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_group_manager_user)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end
  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(3)
      end
    end

  end

end
