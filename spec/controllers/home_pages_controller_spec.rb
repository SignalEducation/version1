# == Schema Information
#
# Table name: home_pages
#
#  id                            :integer          not null, primary key
#  seo_title                     :string
#  seo_description               :string
#  subscription_plan_category_id :integer
#  public_url                    :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  group_id                      :integer
#  subject_course_id             :integer
#

require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'
require 'mandrill_client'

describe HomePagesController, type: :controller do

  include_context 'course_content'
  include_context 'users_and_groups_setup'

  let!(:country_1) { FactoryGirl.create(:ireland) }
  let!(:country_2) { FactoryGirl.create(:uk) }
  let!(:country_3) { FactoryGirl.create(:usa) }
  let!(:home_page_1) { FactoryGirl.create(:home_page) }
  let!(:home_page_2) { FactoryGirl.create(:cfa_home) }
  let!(:home_page_3) { FactoryGirl.create(:home) }
  let!(:valid_params) { FactoryGirl.attributes_for(:home_page) }
  let!(:sign_up_params) { { first_name: "Test", last_name: "Student",
                            locale: 'en',
                            email: "test.student@example.com", password: "dummy_pass",
                            password_confirmation: "dummy_pass" } }
  let!(:default_plan) { FactoryGirl.create(:subscription_plan) }
  let!(:student) { FactoryGirl.create(:individual_student_user) }
  let!(:referral_code) { FactoryGirl.create(:referral_code, user_id: student.id) }

  context 'Not logged in: ' do

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:home)
      end
    end

    describe "GET 'group_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end
    

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "GET 'group_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
      x = admin_user
      y = corporate_student_user
      a = corporate_customer_user
      b = content_manager_user
      z = tutor_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "GET 'group_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
      a = admin_user
      b = corporate_student_user
      c = corporate_customer_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(tutor_dashboard_url)
      end
    end

    describe "GET 'group_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
      a = admin_user
      b = corporate_student_user
      c = corporate_customer_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(corporate_student_dashboard_url)
      end
    end

    describe "GET 'group_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
      a = admin_user
      b = corporate_student_user
      c = corporate_customer_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(corporate_customer_dashboard_url)
      end
    end

    describe "GET 'group_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
      a = admin_user
      b = corporate_student_user
      c = corporate_customer_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
      g = customer_support_manager_user
      h = marketing_manager_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(student_dashboard_url)
      end
    end

    describe "GET 'group_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
      a = admin_user
      b = corporate_student_user
      c = corporate_customer_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
      g = customer_support_manager_user
      h = marketing_manager_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(content_manager_dashboard_url)
      end
    end

    describe "GET 'group_index'" do

      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do

      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
      a = admin_user
      b = corporate_student_user
      c = corporate_customer_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
      g = customer_support_manager_user
      h = marketing_manager_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(customer_support_manager_dashboard_url)
      end
    end

    describe "GET 'group_index'" do

      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do

      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
      a = admin_user
      b = corporate_student_user
      c = corporate_customer_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
      g = customer_support_manager_user
      h = marketing_manager_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(marketing_manager_dashboard_url)
      end
    end

    describe "GET 'group_index'" do

      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do

      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
      a = admin_user
      b = corporate_student_user
      c = corporate_customer_user
      d = content_manager_user
      e = tutor_user
      f = comp_user
    end

    describe "GET 'home'" do
      it 'should see home' do
        get :home
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(admin_dashboard_url)
      end
    end

    describe "GET 'group_index'" do

      let!(:currency_2) { FactoryGirl.create(:gbp) }

      it 'should see group_index' do
        get :group_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_index)
      end
    end

    describe "GET 'diploma_index'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma_index' do
        get :diploma_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(product_course_url(subject_course_1_home_page.public_url))
      end
    end

    describe "GET 'group'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }

      #Passes when run by itself
      xit 'should see group' do
        get :group, home_pages_public_url: home_page_2.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group)
      end
    end

    describe "GET 'diploma'" do
      let!(:currency_2) { FactoryGirl.create(:gbp) }
      let!(:home_page_4) { FactoryGirl.create(:product_1_home) }
      let!(:product) { FactoryGirl.create(:product, subject_course_id: subject_course_3.id) }

      #Passes when run by itself
      xit 'should see diploma' do
        get :diploma, home_pages_public_url: subject_course_1_home_page.public_url
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:diploma)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('home_page')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with home_page_1' do
        get :edit, id: home_page_1.id
        expect_edit_success_with_model('home_page', home_page_1.id)
      end

      # optional
      it 'should respond OK with home_page_2' do
        get :edit, id: home_page_2.id
        expect_edit_success_with_model('home_page', home_page_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, home_page: valid_params
        expect_create_success_with_model('home_page', home_pages_url)
      end

      it 'should report error for invalid params' do
        post :create, home_page: {valid_params.keys.first => ''}
        expect_create_error_with_model('home_page')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for home_page_1' do
        put :update, id: home_page_1.id, home_page: valid_params
        expect_update_success_with_model('home_page', home_pages_url)
      end

      # optional
      it 'should respond OK to valid params for home_page_2' do
        put :update, id: home_page_2.id, home_page: valid_params
        expect_update_success_with_model('home_page', home_pages_url)
        expect(assigns(:home_page).id).to eq(home_page_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: home_page_1.id, home_page: {valid_params.keys.first => ''}
        expect_update_error_with_model('home_page')
        expect(assigns(:home_page).id).to eq(home_page_1.id)
      end
    end

  end

end
