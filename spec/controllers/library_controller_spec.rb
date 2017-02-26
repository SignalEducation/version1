
require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

RSpec.describe LibraryController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:gbp) { FactoryGirl.create(:gbp) }
  let!(:product_1)  { FactoryGirl.create(:product, subject_course_id: subject_course_2.id, currency_id: gbp.id) }

  context 'Not logged in: ' do

    describe "GET index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end
    end

    describe "GET group_show" do
      it "returns http success" do
        get :group_show, group_name_url: course_group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET course_show" do
      it "returns http success" do
        get :course_show, subject_course_name_url: subject_course_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end
    end

    describe "GET group_show" do
      it "returns http success" do
        get :group_show, group_name_url: course_group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET course_show" do
      it "returns http success" do
        get :course_show, subject_course_name_url: subject_course_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end
    end

    describe "GET group_show" do
      it "returns http success" do
        get :group_show, group_name_url: course_group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET course_show" do
      it "returns http success" do
        get :course_show, subject_course_name_url: subject_course_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end
    end

    describe "GET group_show" do
      it "returns http success" do
        get :group_show, group_name_url: course_group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET course_show" do
      it "returns http success" do
        get :course_show, subject_course_name_url: subject_course_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET diploma_show" do
      it "returns http success" do
        get :diploma_show, subject_course_name_url: subject_course_2.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_2.home_page.public_url))

      end

    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end
    end

    describe "GET group_show" do
      it "returns http success" do
        get :group_show, group_name_url: course_group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET course_show" do
      it "returns http success" do
        get :course_show, subject_course_name_url: subject_course_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end
    end

    describe "GET group_show" do
      it "returns http success" do
        get :group_show, group_name_url: course_group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET course_show" do
      it "returns http success" do
        get :course_show, subject_course_name_url: subject_course_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET diploma_show" do
      it "returns http success" do
        get :diploma_show, subject_course_name_url: subject_course_2.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_2.home_page.public_url))

      end

    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end
    end

    describe "GET group_show" do
      it "returns http success" do
        get :group_show, group_name_url: course_group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET course_show" do
      it "returns http success" do
        get :course_show, subject_course_name_url: subject_course_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end
    end

    describe "GET group_show" do
      it "returns http success" do
        get :group_show, group_name_url: course_group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET course_show" do
      it "returns http success" do
        get :course_show, subject_course_name_url: subject_course_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end
    end

    describe "GET group_show" do
      it "returns http success" do
        get :group_show, group_name_url: course_group_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

    describe "GET course_show" do
      it "returns http success" do
        get :course_show, subject_course_name_url: subject_course_1.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.count).to eq(2)
        expect(SubjectCourse.count).to eq(4)
      end
    end

  end

end
