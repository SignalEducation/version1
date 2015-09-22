require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe QuestionBanksController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  # todo: Try to create children for question_bank_1
  let!(:question_bank_1) { FactoryGirl.create(:question_bank) }
  let!(:valid_params) { FactoryGirl.attributes_for(:question_bank) }

  context 'Not logged in: ' do

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
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

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, exam_level_name_url: exam_level_1.name_url
        expect_new_success_with_model('question_bank')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, question_bank: valid_params, subject_course_name_url: subject_course_1.name_url
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(subject.course_special_link(assigns(:question_bank)))
      end

      it 'should report error for invalid params' do
        post :new, question_bank: {valid_params.keys.first => ''},
                      exam_level_name_url: exam_level_1.name_url
        expect_create_error_with_model('question_bank')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: question_bank_2.id
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(assigns('question_bank'.to_sym).class.name).to eq('question_bank'.classify)
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, exam_level_name_url: exam_level_1.name_url
        expect_new_success_with_model('question_bank')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, question_bank: valid_params, exam_level_name_url: exam_level_1.name_url
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(subject.course_special_link(assigns(:question_bank)))
      end

      it 'should report error for invalid params' do
        post :new, question_bank: {valid_params.keys.first => ''},
             exam_level_name_url: exam_level_1.name_url
        expect_create_error_with_model('question_bank')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: question_bank_2.id
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(assigns('question_bank'.to_sym).class.name).to eq('question_bank'.classify)
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, exam_level_name_url: exam_level_1.name_url
        expect_new_success_with_model('question_bank')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, question_bank: valid_params, exam_level_name_url: exam_level_1.name_url
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(subject.course_special_link(assigns(:question_bank)))
      end

      it 'should report error for invalid params' do
        post :new, question_bank: {valid_params.keys.first => ''},
             exam_level_name_url: exam_level_1.name_url
        expect_create_error_with_model('question_bank')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: question_bank_2.id
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(assigns('question_bank'.to_sym).class.name).to eq('question_bank'.classify)
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, exam_level_name_url: exam_level_1.name_url
        expect_new_success_with_model('question_bank')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, question_bank: valid_params, exam_level_name_url: exam_level_1.name_url
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(subject.course_special_link(assigns(:question_bank)))
      end

      it 'should report error for invalid params' do
        post :new, question_bank: {valid_params.keys.first => ''},
             exam_level_name_url: exam_level_1.name_url
        expect_create_error_with_model('question_bank')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: question_bank_2.id
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(assigns('question_bank'.to_sym).class.name).to eq('question_bank'.classify)
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, exam_level_name_url: exam_level_1.name_url
        expect_new_success_with_model('question_bank')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, question_bank: valid_params, exam_level_name_url: exam_level_1.name_url
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(subject.course_special_link(assigns(:question_bank)))
      end

      it 'should report error for invalid params' do
        post :new, question_bank: {valid_params.keys.first => ''},
             exam_level_name_url: exam_level_1.name_url
        expect_create_error_with_model('question_bank')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: question_bank_2.id
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(assigns('question_bank'.to_sym).class.name).to eq('question_bank'.classify)
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, exam_level_name_url: exam_level_1.name_url
        expect_new_success_with_model('question_bank')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, question_bank: valid_params, exam_level_name_url: exam_level_1.name_url
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(subject.course_special_link(assigns(:question_bank)))
      end

      it 'should report error for invalid params' do
        post :new, question_bank: {valid_params.keys.first => ''},
             exam_level_name_url: exam_level_1.name_url
        expect_create_error_with_model('question_bank')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: question_bank_2.id
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(assigns('question_bank'.to_sym).class.name).to eq('question_bank'.classify)
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, exam_level_name_url: exam_level_1.name_url
        expect_new_success_with_model('question_bank')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, question_bank: valid_params, exam_level_name_url: exam_level_1.name_url
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to question_bank_url
      end

      it 'should report error for invalid params' do
        post :new, question_bank: {valid_params.keys.first => ''},
             exam_level_name_url: exam_level_1.name_url
        expect_create_error_with_model('question_bank')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: question_bank_2.id
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(assigns('question_bank'.to_sym).class.name).to eq('question_bank'.classify)
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, exam_level_name_url: exam_level_1.name_url
        expect_new_success_with_model('question_bank')
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, question_bank: valid_params, exam_level_name_url: exam_level_1.name_url
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(subject.course_special_link(assigns(:question_bank)))
      end

      it 'should report error for invalid params' do
        post :new, question_bank: {valid_params.keys.first => ''},
             exam_level_name_url: exam_level_1.name_url
        expect_create_error_with_model('question_bank')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: question_bank_2.id
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(assigns('question_bank'.to_sym).class.name).to eq('question_bank'.classify)
      end
    end

  end

end
