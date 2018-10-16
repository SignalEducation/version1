require 'rails_helper'
require 'stripe_mock'

describe UserAccountsController, type: :controller do

  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:valid_subscription_student) { FactoryBot.create(:valid_subscription_student, user_group_id: student_user_group.id) }
  let!(:valid_subscription_student_access) { FactoryBot.create(:trial_student_access, user_id: valid_subscription_student.id) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course, group_id: group_1.id, exam_body_id: 1) }
  let!(:enrollment_1) { FactoryBot.create(:enrollment, user_id: valid_subscription_student.id, subject_course_id: subject_course_1.id, exam_body_id: 1) }

  let!(:valid_subscription) { FactoryBot.create(:valid_subscription, user_id: valid_subscription_student.id,
                                                stripe_customer_id: valid_subscription_student.stripe_customer_id ) }



  context 'Logged in as a valid_subscription_student' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
    end

    describe "GET account_show" do
      it 'should see account_show' do
        get :account_show
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account_show)
      end
    end

    describe "Post 'update_user'" do
      #TODO - add bad params test
      it 'should report OK for valid params' do
        put :update_user, id: valid_subscription_student.id, user: {name: 'John'}
        expect(flash[:success]).to eq(I18n.t('controllers.users.update.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response.status).to redirect_to(account_url)
      end
    end

    describe "Post 'update_exam_body_user_details'" do
      #TODO - add bad params test
      it 'should report OK for valid params' do
        post :update_exam_body_user_details, id: valid_subscription_student.id, user: {student_number: '123456789'}
        expect(flash[:success]).to eq(I18n.t('controllers.users.update_exam_body_details.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response.status).to redirect_to(library_course_url(group_name_url: group_1.name_url, subject_course_name_url: subject_course_1.name_url))
      end
    end

    describe "Post 'change_password'" do
      #TODO - add bad params test
      it 'should report OK for valid params' do
        put :change_password, user: {current_password: valid_subscription_student.password, password: '123123123',
                                     password_confirmation: '123123123', id: valid_subscription_student.id}

        expect(flash[:success]).to eq(I18n.t('controllers.users.change_password.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response.status).to redirect_to(account_url)
      end
    end

    describe "Get 'subscription_invoice'" do
      #TODO - create an Invoice record
      xit 'should redirect to root' do
        get :subscription_invoice, id: valid_subscription.invoices.last
        expect(flash[:success]).to eq(I18n.t('controllers.users.update.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response.status).to redirect_to(account_url)
      end
    end

  end
end