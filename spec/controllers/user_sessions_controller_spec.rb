require 'rails_helper'

RSpec.describe UserSessionsController, type: :controller do
  let!(:student_user)        { create(:student_user) }
  let!(:corrections_user)    { create(:exercise_corrections_user) }
  let(:exercise)             { create(:exercise) }
  let(:other_exercise)       { create(:exercise) }

  describe 'GET new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
      expect(response).to render_template('new')
    end
  end

  describe 'POST create' do
    let(:user)           { create(:user) }
    let(:subject_course) { create(:subject_course) }

    subject do
      post :create, params: { user_session: { email: user.email, password: user.password } }
    end

    context 'successfully login' do
      it 'redirect after login' do
        subject
        expect(response).to be_redirect
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(student_dashboard_url)
      end

      it 'redirect to new_subscription_url after login' do
        allow_any_instance_of(UserSessionsController).to receive(:flash).and_return(plan_guid: 'plan_guid')
        subject

        expect(response).to be_redirect
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_subscription_url(plan_guid: 'plan_guid', login: true))
      end

      it 'redirect to product_id after login' do
        allow_any_instance_of(UserSessionsController).to receive(:flash).and_return(product_id: 'product_id')
        subject

        expect(response).to be_redirect
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_product_order_url(product_id: 'product_id', login: true))
      end

      it 'redirect to redirect_back_or_default after login' do
        allow_any_instance_of(UserSessionsController).to receive(:session).and_return(return_to: root_url)
        subject

        expect(response).to be_redirect
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_url)
      end

      it 'redirect to course_enrollment_special_link after login' do
        allow_any_instance_of(UserSessionsController).to receive(:course_enrollment_special_link).and_return('')
        allow_any_instance_of(UserSessionsController).to receive(:handle_course_enrollment).and_return(true)

        post :create, params: { user_session: { email: user.email, password: user.password }, subject_course_id: subject_course.id }

        expect(response).to be_redirect
        expect(response).to have_http_status(:redirect)
      end

      it 'redirect to student_dashboard_url after login' do
        allow_any_instance_of(UserSessionsController).to receive(:flash).and_return(plan_guid: 'plan_guid')
        allow_any_instance_of(UserSession).to receive(:save).and_return(false)

        subject

        expect(response).to be_redirect
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(sign_in_url)
      end

      it 'render new' do
        allow_any_instance_of(UserSession).to receive(:save).and_return(false)

        subject

        expect(response).to have_http_status(:success)
        expect(response).to render_template('new')
      end

      it 'render new' do
        expect_any_instance_of(UserSession).to receive(:save).and_raise(ActionController::InvalidAuthenticityToken)
        subject

        expect(response).to be_redirect
        expect(response).to have_http_status(:redirect)
      end
    end

    it 'error after try login' do
      post :create, params: { user_session: { email: user.email, password: (user.password + 'pass') } }

      expect(response.status).to eq(200)
    end
  end

  describe "get 'destroy'" do
    it 'redirect to home' do
      activate_authlogic
      UserSession.create!(student_user)

      get :destroy
      expect(response).to be_redirect
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'methods' do
    let(:user)           { create(:user) }
    let(:subject_course) { create(:subject_course) }

    it '.handle_course_enrollment' do
      user_session = UserSessionsController.new
      response = user_session.send(:handle_course_enrollment, user, subject_course.id)

      expect(response).to include(nil, "Sorry! Bootcamp is not currently available for #{subject_course.name}")
    end
  end
end
