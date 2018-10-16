require 'rails_helper'

RSpec.describe EnrollmentManagementController, :type => :controller do

  let(:user_management_user_group) { FactoryBot.create(:user_management_user_group) }
  let(:user_management_user) { FactoryBot.create(:user_management_user,
                                                 user_group_id: user_management_user_group.id) }
  let!(:user_management_student_access) { FactoryBot.create(:complimentary_student_access,
                                                            user_id: user_management_user.id) }
  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }

  let!(:enrollment_1) { FactoryBot.create(:enrollment, subject_course_id: subject_course_1.id) }
  let!(:enrollment_2) { FactoryBot.create(:enrollment, subject_course_id: subject_course_1.id) }
  let!(:valid_params) { FactoryBot.attributes_for(:enrollment,
                                                  exam_date: '2018-08-18') }

  context 'Logged in as a user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe 'GET index' do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('enrollments', 2)
      end
    end

    describe 'GET edit' do
      it 'should respond OK with enrollment_1' do
        get :edit, id: enrollment_1.id
        expect_edit_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe 'PUT update' do
      it 'should respond OK to valid params for enrollment_1' do
        put :update, id: enrollment_1.id, enrollment: valid_params
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.admin_update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(enrollment_management_url(enrollment_1))
      end
    end

    describe 'GET show' do
      it 'should see enrollment_1' do
        get :show, id: enrollment_1.id
        expect_show_success_with_model('enrollment', enrollment_1.id)
      end
    end

    describe 'POST create_new_scul' do
      it 'should respond OK to enrollment_1 id' do
        post :create_new_scul, id: enrollment_1.id
        expect(flash[:success]).to eq(I18n.t('controllers.enrollments.admin_create_new_scul.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(enrollment_management_url(enrollment_1))

      end
    end

  end


end