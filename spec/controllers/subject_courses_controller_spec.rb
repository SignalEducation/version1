# == Schema Information
#
# Table name: subject_courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  live                                    :boolean          default(FALSE), not null
#  wistia_guid                             :string
#  tutor_id                                :integer
#  cme_count                               :integer
#  video_count                             :integer
#  quiz_count                              :integer
#  question_count                          :integer
#  description                             :text
#  short_description                       :string
#  mailchimp_guid                          :string
#  forum_url                               :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  best_possible_first_attempt_score       :float
#  default_number_of_possible_exam_answers :integer
#  restricted                              :boolean          default(FALSE), not null
#  corporate_customer_id                   :integer
#  total_video_duration                    :float            default(0.0)
#  destroyed_at                            :datetime
#  is_cpd                                  :boolean          default(FALSE)
#  cpd_hours                               :float
#  cpd_pass_rate                           :integer
#  live_date                               :datetime
#  certificate                             :boolean          default(FALSE), not null
#  hotjar_guid                             :string
#

require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe SubjectCoursesController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:subject_course_3) { FactoryGirl.create(:inactive_subject_course) }
  let!(:valid_params) { FactoryGirl.attributes_for(:subject_course) }

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

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :create, array_of_ids: [1,2]
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
      it 'should see subject_course_1' do
        get :show, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see subject_course_2' do
        get :show, id: subject_course_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_1' do
        get :edit, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with subject_course_2' do
        get :edit, id: subject_course_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_1' do
        put :update, id: subject_course_1.id, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_1.id, subject_course: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [subject_course_2.id, subject_course_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_2.id
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
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(assigns('subject_courses'.to_sym).count).to eq(0)

      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_1' do
        get :show, id: subject_course_1.id
        expect_show_success_with_model('subject_course', subject_course_1.id)
      end

      # optional - some other object
      it 'should see subject_course_2' do
        get :show, id: subject_course_2.id
        expect_show_success_with_model('subject_course', subject_course_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subject_course')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_1' do
        get :edit, id: subject_course_1.id
        expect_edit_success_with_model('subject_course', subject_course_1.id)
      end

      # optional
      it 'should respond OK with subject_course_2' do
        get :edit, id: subject_course_2.id
        expect_edit_success_with_model('subject_course', subject_course_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course: valid_params
        expect_create_success_with_model('subject_course', subject_courses_url)
      end

      it 'should report error for invalid params' do
        post :create, subject_course: {valid_params.keys.first => ''}
        expect_create_error_with_model('subject_course')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_1' do
        put :update, id: subject_course_1.id, subject_course: valid_params
        expect_update_success_with_model('subject_course', subject_courses_url)
      end

      # optional
      it 'should respond OK to valid params for subject_course_2' do
        put :update, id: subject_course_2.id, subject_course: valid_params
        expect_update_success_with_model('subject_course', subject_courses_url)
        expect(assigns(:subject_course).id).to eq(subject_course_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_1.id, subject_course: {valid_params.keys.first => ''}
        expect_update_error_with_model('subject_course')
        expect(assigns(:subject_course).id).to eq(subject_course_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [subject_course_2.id, subject_course_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, id: subject_course_1.id
        expect_archive_success_with_model('subject_course', subject_course_1.id, subject_courses_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_3.id
        expect_delete_success_with_model('subject_course', subject_courses_url)
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
      it 'should see subject_course_1' do
        get :show, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see subject_course_2' do
        get :show, id: subject_course_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_1' do
        get :edit, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with subject_course_2' do
        get :edit, id: subject_course_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_1' do
        put :update, id: subject_course_1.id, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for subject_course_2' do
        put :update, id: subject_course_2.id, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_1.id, subject_course: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [subject_course_2.id, subject_course_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_2.id
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
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(assigns('subject_courses'.to_sym).count).to eq(0)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_1' do
        get :show, id: subject_course_1.id
        expect_show_success_with_model('subject_course', subject_course_1.id)
      end

      # optional - some other object
      it 'should see subject_course_2' do
        get :show, id: subject_course_2.id
        expect_show_success_with_model('subject_course', subject_course_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subject_course')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_1' do
        get :edit, id: subject_course_1.id
        expect_edit_success_with_model('subject_course', subject_course_1.id)
      end

      # optional
      it 'should respond OK with subject_course_2' do
        get :edit, id: subject_course_2.id
        expect_edit_success_with_model('subject_course', subject_course_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course: valid_params
        expect_create_success_with_model('subject_course', subject_courses_url)
      end

      it 'should report error for invalid params' do
        post :create, subject_course: {valid_params.keys.first => ''}
        expect_create_error_with_model('subject_course')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_1' do
        put :update, id: subject_course_1.id, subject_course: valid_params
        expect_update_success_with_model('subject_course', subject_courses_url)
      end

      # optional
      it 'should respond OK to valid params for subject_course_2' do
        put :update, id: subject_course_2.id, subject_course: valid_params
        expect_update_success_with_model('subject_course', subject_courses_url)
        expect(assigns(:subject_course).id).to eq(subject_course_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_1.id, subject_course: {valid_params.keys.first => ''}
        expect_update_error_with_model('subject_course')
        expect(assigns(:subject_course).id).to eq(subject_course_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [subject_course_2.id, subject_course_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, id: subject_course_1.id
        expect_archive_success_with_model('subject_course', subject_course_1.id, subject_courses_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_3.id
        expect_delete_success_with_model('subject_course', subject_courses_url)
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
      it 'should see subject_course_1' do
        get :show, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see subject_course_2' do
        get :show, id: subject_course_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_1' do
        get :edit, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with subject_course_2' do
        get :edit, id: subject_course_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_1' do
        put :update, id: subject_course_1.id, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for subject_course_2' do
        put :update, id: subject_course_2.id, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_1.id, subject_course: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [subject_course_2.id, subject_course_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_1' do
        get :show, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see subject_course_2' do
        get :show, id: subject_course_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_1' do
        get :edit, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with subject_course_2' do
        get :edit, id: subject_course_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_1' do
        put :update, id: subject_course_1.id, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for subject_course_2' do
        put :update, id: subject_course_2.id, subject_course: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_1.id, subject_course: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [subject_course_2.id, subject_course_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_2.id
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
        expect_index_success_with_model('subject_courses', 3)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_1' do
        get :show, id: subject_course_1.id
        expect_show_success_with_model('subject_course', subject_course_1.id)
      end

      # optional - some other object
      it 'should see subject_course_2' do
        get :show, id: subject_course_2.id
        expect_show_success_with_model('subject_course', subject_course_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subject_course')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_1' do
        get :edit, id: subject_course_1.id
        expect_edit_success_with_model('subject_course', subject_course_1.id)
      end

      # optional
      it 'should respond OK with subject_course_2' do
        get :edit, id: subject_course_2.id
        expect_edit_success_with_model('subject_course', subject_course_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course: valid_params
        expect_create_success_with_model('subject_course', subject_courses_url)
      end

      it 'should report error for invalid params' do
        post :create, subject_course: {valid_params.keys.first => ''}
        expect_create_error_with_model('subject_course')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_1' do
        put :update, id: subject_course_1.id, subject_course: valid_params
        expect_update_success_with_model('subject_course', subject_courses_url)
      end

      # optional
      it 'should respond OK to valid params for subject_course_2' do
        put :update, id: subject_course_2.id, subject_course: valid_params
        expect_update_success_with_model('subject_course', subject_courses_url)
        expect(assigns(:subject_course).id).to eq(subject_course_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_1.id, subject_course: {valid_params.keys.first => ''}
        expect_update_error_with_model('subject_course')
        expect(assigns(:subject_course).id).to eq(subject_course_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [subject_course_2.id, subject_course_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, id: subject_course_1.id
        expect_archive_success_with_model('subject_course', subject_course_1.id, subject_courses_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_3.id
        expect_delete_success_with_model('subject_course', subject_courses_url)
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
        expect_index_success_with_model('subject_courses', 3)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_1' do
        get :show, id: subject_course_1.id
        expect_show_success_with_model('subject_course', subject_course_1.id)
      end

      # optional - some other object
      it 'should see subject_course_2' do
        get :show, id: subject_course_2.id
        expect_show_success_with_model('subject_course', subject_course_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subject_course')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_1' do
        get :edit, id: subject_course_1.id
        expect_edit_success_with_model('subject_course', subject_course_1.id)
      end

      # optional
      it 'should respond OK with subject_course_2' do
        get :edit, id: subject_course_2.id
        expect_edit_success_with_model('subject_course', subject_course_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course: valid_params
        expect_create_success_with_model('subject_course', subject_courses_url)
      end

      it 'should report error for invalid params' do
        post :create, subject_course: {valid_params.keys.first => ''}
        expect_create_error_with_model('subject_course')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_1' do
        put :update, id: subject_course_1.id, subject_course: valid_params
        expect_update_success_with_model('subject_course', subject_courses_url)
      end

      # optional
      it 'should respond OK to valid params for subject_course_2' do
        put :update, id: subject_course_2.id, subject_course: valid_params
        expect_update_success_with_model('subject_course', subject_courses_url)
        expect(assigns(:subject_course).id).to eq(subject_course_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_1.id, subject_course: {valid_params.keys.first => ''}
        expect_update_error_with_model('subject_course')
        expect(assigns(:subject_course).id).to eq(subject_course_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [subject_course_2.id, subject_course_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK even though dependencies exist' do
        delete :destroy, id: subject_course_1.id
        expect_archive_success_with_model('subject_course', subject_course_1.id, subject_courses_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_3.id
        expect_delete_success_with_model('subject_course', subject_courses_url)
      end
    end

  end

end
