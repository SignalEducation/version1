# == Schema Information
#
# Table name: course_tutors
#
#  id                :integer          not null, primary key
#  course_id :integer
#  user_id           :integer
#  sorting_order     :integer
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe Admin::CourseTutorsController, type: :controller do

  include_context 'users_and_groups_setup'
  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1)     { FactoryBot.create(:group) }
  let!(:course_1)    { FactoryBot.create(:active_course,
                                          group_id: group_1.id,
                                          exam_body_id: exam_body_1.id) }

  let!(:course_tutor_1) { FactoryBot.create(:course_tutor, course_id: course_1.id, user_id: tutor_user.id) }
  let!(:course_tutor_2) { FactoryBot.create(:course_tutor, course_id: course_1.id, user_id: tutor_user.id) }
  let!(:valid_params) { FactoryBot.attributes_for(:course_tutor, course_id: course_1.id, user_id: tutor_user.id) }


  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index, params: { course_id: course_1.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, params: { course_id: course_1.id }
        expect_new_success_with_model('course_tutor')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_tutor_1' do
        get :edit, params: { id: course_tutor_1.id, course_id: course_1.id }
        expect_edit_success_with_model('course_tutor', course_tutor_1.id)
      end

      # optional
      it 'should respond OK with course_tutor_2' do
        get :edit, params: { id: course_tutor_2.id, course_id: course_1.id }
        expect_edit_success_with_model('course_tutor', course_tutor_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { course_id: course_1.id, course_tutor: valid_params }
        expect_create_success_with_model('course_tutor', admin_course_course_tutors_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { course_id: course_1.id, course_tutor: {valid_params.keys.first => ''} }
        expect_create_error_with_model('course_tutor')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_tutor_1' do
        put :update, params: { course_id: course_1.id, id: course_tutor_1.id, course_tutor: valid_params }
        expect_update_success_with_model('course_tutor', admin_course_course_tutors_url)
      end

      # optional
      it 'should respond OK to valid params for course_tutor_2' do
        put :update, params: { course_id: course_1.id, id: course_tutor_2.id, course_tutor: valid_params }
        expect_update_success_with_model('course_tutor', admin_course_course_tutors_url)
        expect(assigns(:course_tutor).id).to eq(course_tutor_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { course_id: course_1.id, id: course_tutor_1.id, course_tutor: {valid_params.keys.first => ''} }
        expect_update_error_with_model('course_tutor')
        expect(assigns(:course_tutor).id).to eq(course_tutor_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { course_id: course_1.id, array_of_ids: [course_tutor_2.id, course_tutor_1.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { course_id: course_1.id, id: course_tutor_2.id }
        expect_delete_success_with_model('course_tutor', admin_course_course_tutors_url)
      end
    end
  end
end
