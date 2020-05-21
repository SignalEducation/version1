# == Schema Information
#
# Table name: exam_sittings
#
#  id                :integer          not null, primary key
#  name              :string
#  course_id :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  exam_body_id      :integer
#  active            :boolean          default(TRUE)
#  computer_based    :boolean          default(FALSE)
#

require 'rails_helper'

describe ExamSittingsController, type: :controller do

  let(:system_requirements_user_group) { FactoryBot.create(:system_requirements_user_group) }
  let(:system_requirements_user) { FactoryBot.create(:system_requirements_user,
                                                     user_group_id: system_requirements_user_group.id) }

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:course_1)  { FactoryBot.create(:active_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:exam_sitting_1) { FactoryBot.create(:exam_sitting, exam_body_id: exam_body_1.id, course_id: course_1.id) }
  let!(:exam_sitting_2) { FactoryBot.create(:exam_sitting, exam_body_id: exam_body_1.id, course_id: course_1.id) }
  let!(:valid_params) { FactoryBot.attributes_for(:exam_sitting, exam_body_id: exam_body_1.id, course_id: course_1.id) }

  context 'Logged in as a system_requirements_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(system_requirements_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('exam_sittings', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see exam_sitting_1' do
        get :show, params: { id: exam_sitting_1.id }
        expect_show_success_with_model('exam_sitting', exam_sitting_1.id)
      end

      # optional - some other object
      it 'should see exam_sitting_2' do
        get :show, params: { id: exam_sitting_2.id }
        expect_show_success_with_model('exam_sitting', exam_sitting_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('exam_sitting')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with exam_sitting_1' do
        get :edit, params: { id: exam_sitting_1.id }
        expect_edit_success_with_model('exam_sitting', exam_sitting_1.id)
      end

      # optional
      it 'should respond OK with exam_sitting_2' do
        get :edit, params: { id: exam_sitting_2.id }
        expect_edit_success_with_model('exam_sitting', exam_sitting_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { exam_sitting: valid_params }
        expect_create_success_with_model('exam_sitting', exam_sittings_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { exam_sitting: {valid_params.keys.first => ''} }
        expect_create_error_with_model('exam_sitting')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for exam_sitting_1' do
        put :update, params: { id: exam_sitting_1.id, exam_sitting: valid_params }
        expect_update_success_with_model('exam_sitting', exam_sittings_url)
      end

      # optional
      it 'should respond OK to valid params for exam_sitting_2' do
        put :update, params: { id: exam_sitting_2.id, exam_sitting: valid_params }
        expect_update_success_with_model('exam_sitting', exam_sittings_url)
        expect(assigns(:exam_sitting).id).to eq(exam_sitting_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: exam_sitting_1.id, exam_sitting: {valid_params.keys.first => ''} }
        expect_update_error_with_model('exam_sitting')
        expect(assigns(:exam_sitting).id).to eq(exam_sitting_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be errors as not allowed' do
        delete :destroy, params: { id: exam_sitting_2.id }
        expect_delete_error_with_model('exam_sitting', exam_sittings_url)
      end
    end

  end

end
