# == Schema Information
#
# Table name: mock_exams
#
#  id                       :integer          not null, primary key
#  course_id        :integer
#  product_id               :integer
#  name                     :string
#  sorting_order            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_file_name           :string
#  file_content_type        :string
#  file_file_size           :integer
#  file_updated_at          :datetime
#  cover_image_file_name    :string
#  cover_image_content_type :string
#  cover_image_file_size    :integer
#  cover_image_updated_at   :datetime
#

require 'rails_helper'

describe MockExamsController, type: :controller do
  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user)       { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:exam_body)                    { FactoryBot.create(:exam_body) }
  let!(:group)                        { FactoryBot.create(:group) }
  let!(:course)               { FactoryBot.create(:active_course,
                                                          group_id: group.id,
                                                          exam_body_id: exam_body.id) }

  let(:currency)                      { FactoryBot.create(:currency) }
  let!(:mock_exam_1)                  { FactoryBot.create(:mock_exam, name: 'Mock ABC', course: course) }
  let!(:mock_exam_2)                  { FactoryBot.create(:mock_exam, course: course) }

  let!(:order_1)                      { FactoryBot.create(:order, mock_exam_id: mock_exam_1.id, stripe_order_payment_data: { currency: currency.iso_code} ) }
  let!(:valid_params)                 { FactoryBot.attributes_for(:mock_exam, course_id: course.id) }

  context 'Logged in as a content_management_user: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('mock_exams', 3)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('mock_exam')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with mock_exam_1' do
        get :edit, params: { id: mock_exam_1.id }
        expect_edit_success_with_model('mock_exam', mock_exam_1.id)
      end

      # optional
      it 'should respond OK with mock_exam_2' do
        get :edit, params: { id: mock_exam_2.id }
        expect_edit_success_with_model('mock_exam', mock_exam_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { mock_exam: valid_params }
        expect_create_success_with_model('mock_exam', mock_exams_url)
      end

      it 'should report error for invalid params' do
        post :create, params: { mock_exam: { valid_params.keys.first => '' } }
        expect_create_error_with_model('mock_exam')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for mock_exam_1' do
        put :update, params: { id: mock_exam_1.id, mock_exam: valid_params }
        expect_update_success_with_model('mock_exam', mock_exams_url)
      end

      # optional
      it 'should respond OK to valid params for mock_exam_2' do
        put :update, params: { id: mock_exam_2.id, mock_exam: valid_params }
        expect_update_success_with_model('mock_exam', mock_exams_url)
        expect(assigns(:mock_exam).id).to eq(mock_exam_2.id)
      end

      it 'should reject invalid params' do
        put :update, params: { id: mock_exam_1.id, mock_exam: { valid_params.keys.first => '' } }
        expect_update_error_with_model('mock_exam')
        expect(assigns(:mock_exam).id).to eq(mock_exam_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, params: { array_of_ids: [mock_exam_2.id, mock_exam_1.id] }
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, params: { id: mock_exam_1.id }
        expect_delete_error_with_model('mock_exam', mock_exams_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, params: { id: mock_exam_2.id }
        expect_delete_success_with_model('mock_exam', mock_exams_url)
      end
    end
  end
end
