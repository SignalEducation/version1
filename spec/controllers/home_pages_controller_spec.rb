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
#  subject_course_id             :integer
#  custom_file_name              :string
#  group_id                      :integer
#  name                          :string
#  home                          :boolean          default(FALSE)
#  header_heading                :string
#  header_paragraph              :text
#  header_button_text            :string
#  background_image              :string
#  header_button_link            :string
#  header_button_subtext         :string
#  footer_link                   :boolean          default(FALSE)
#  mailchimp_list_guid           :string
#  mailchimp_section_heading     :string
#  mailchimp_section_subheading  :string
#  mailchimp_subscribe_section   :boolean          default(FALSE)
#

require 'rails_helper'

describe HomePagesController, type: :controller do

  let(:system_requirements_user_group) { FactoryBot.create(:system_requirements_user_group) }
  let(:system_requirements_user) { FactoryBot.create(:system_requirements_user, user_group_id: system_requirements_user_group.id) }
  let!(:system_requirements_student_access) { FactoryBot.create(:complimentary_student_access, user_id: system_requirements_user.id) }

  let!(:landing_page_1) { FactoryBot.create(:landing_page_1) }
  let!(:landing_page_2) { FactoryBot.create(:landing_page_2) }

  let!(:valid_params) { FactoryBot.attributes_for(:home_page) }

  context 'Logged in as a system_requirements_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(system_requirements_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('home_pages', 2)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('home_page')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with landing_page_1' do
        get :edit, params: { id: landing_page_1.id }
        expect_edit_success_with_model('home_page', landing_page_1.id)
      end

      # optional
      it 'should respond OK with landing_page_2' do
        get :edit, params: { id: landing_page_2.id }
        expect_edit_success_with_model('home_page', landing_page_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { home_page: valid_params }
        expect_create_success_with_model('home_page', home_pages_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { home_page: {valid_params.keys.first => ''} }
        expect_create_error_with_model('home_page')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for landing_page_1' do
        put :update, params: { id: landing_page_1.id, home_page: valid_params }
        expect_update_success_with_model('home_page', home_pages_url)
      end

      # optional
      it 'should respond OK to valid params for landing_page_2' do
        put :update, params: { id: landing_page_2.id, home_page: valid_params }
        expect_update_success_with_model('home_page', home_pages_url)
        expect(assigns(:home_page).id).to eq(landing_page_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: landing_page_1.id, home_page: {valid_params.keys.first => ''} }
        expect_update_error_with_model('home_page')
        expect(assigns(:home_page).id).to eq(landing_page_1.id)
      end
    end

    describe "PUT 'destroy'" do
      it 'should respond OK with delete' do
        put :destroy, params: { id: landing_page_1.id }
        expect_delete_success_with_model('home_page', home_pages_url)
      end
    end

  end

end
