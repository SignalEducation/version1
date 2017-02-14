
require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

RSpec.describe LibraryController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:gbp) { FactoryGirl.create(:gbp) }
  let!(:product_1)  { FactoryGirl.create(:product, subject_course_id: subject_course_3.id, currency_id: gbp.id) }

  context 'Not logged in: ' do

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
      it "redirects because not purchased by user" do
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_3.home_page.public_url))

      end

      it "returns http success because purchased by user" do

        #TODO Change this to use the Stripe Mock Gem
        student_order = Order.create!(product_id: product_1.id, subject_course_id: subject_course_3.id, user_id: individual_student_user.id, current_status: 'paid', stripe_guid: 'MyString', stripe_customer_id: 'MyString', live_mode: false, terms_and_conditions: true)

        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma_show)
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

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
      it "redirects because not purchased by user" do
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_3.home_page.public_url))
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_3.home_page.public_url))

      end

    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end

    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)

      end

    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_3.home_page.public_url))

      end

    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_3.home_page.public_url))

      end

    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_3.home_page.public_url))

      end

    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_3.home_page.public_url))

      end

    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET group_index" do
      it "returns http success" do
        get :group_index
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
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
        get :diploma_show, subject_course_name_url: subject_course_3.name_url
        expect(flash[:success]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma_show)
      end

    end

  end

end
