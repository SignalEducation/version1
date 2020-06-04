# frozen_string_literal: true

require 'rails_helper'

describe Admin::ExercisesController, type: :controller do
  let!(:student_user)        { create(:student_user) }
  let!(:corrections_user)    { create(:exercise_corrections_user) }

  let(:exercise)             { create(:exercise) }
  let(:other_exercise)       { create(:exercise) }

  context 'Logged in as a normal admin user' do
    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "GET 'index'" do
      it 'redirects the user' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/#id'" do
      it 'redirects the user' do
        get :show, params: { id: exercise.id }
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET /users/:user_id/new' do
      it 'redirects the user' do
        get :new, params: { user_id: exercise.user_id }
        expect_bounce_as_not_allowed
      end
    end

    describe 'POST create' do
      it 'redirects the user' do
        post :create, params: {
          exercise: { product_id: exercise.product_id },
          user_id: exercise.user_id
        }
        expect_bounce_as_not_allowed
      end
    end

    describe 'GET edit/#id' do
      it 'redirects the user' do
        get :edit, params: { id: exercise.id }
        expect_bounce_as_not_allowed
      end
    end

    describe 'PUT update/#id' do
      let(:product_2) { create(:product) }

      it 'redirects the user' do
        put :update, params: { id: exercise.id, exercise: { product_id: product_2.id } }
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a exercise_corrections_access user' do
    before(:each) do
      activate_authlogic
      UserSession.create!(corrections_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
      end
    end

    describe "GET 'show/#id'" do
      it 'shows the correct exercise' do
        get :show, params: { id: exercise.id }
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
        expect(assigns(:exercise).id).to eq exercise.id
      end

      it 'shows other_exercise' do
        get :show, params: { id: other_exercise.id }
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
        expect(assigns(:exercise).id).to be other_exercise.id
      end
    end

    describe 'GET /users/:user_id/new' do
      it 'builds see a new exercise' do
        get :new, params: { user_id: exercise.user_id }
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
        expect(assigns(:exercise)).to be_new_record
      end
    end

    describe 'POST create' do
      it 'creates a new exercise' do
        post :create, params: {
          exercise: { product_id: exercise.product_id, order_id: exercise.order.id },
          user_id: exercise.user_id
        }
        expect_create_success_with_model(
          'exercise',
          admin_user_exercises_url(exercise.user),
          'Pending exercise successfully created'
        )
      end
    end

    describe 'GET edit/#id' do
      it 'loads the correct exercise' do
        get :edit, params: { id: exercise.id }
        expect(response.status).to eq(200)
        expect(response).to render_template(:edit)
        expect(assigns(:exercise).id).to be exercise.id
      end
    end

    describe 'PUT update/#id' do
      let(:product_2) { create(:product) }

      it 'should respond OK to valid params for exercise' do
        put :update, params: { id: exercise.id, exercise: { product_id: product_2.id } }
        expect_update_success_with_model('exercise', admin_exercises_url)
      end

      it 'should reject invalid params' do
        put :update, params: { id: exercise.id, exercise: { product_id: 244 } }
        expect_update_error_with_model('exercise')
        expect(assigns(:exercise).id).to eq(exercise.id)
      end
    end

    describe 'GET generate_daily_summary' do
      it 'calls #send_daily_orders_update on the Order model' do
        expect(Order).to receive(:send_daily_orders_update)

        get :generate_daily_summary
      end
      it 'redirects to the correct url with flash' do
        get :generate_daily_summary
        expect(response).to redirect_to(admin_exercises_url)
      end
    end

    context 'CBE Exercises' do
      let(:exercise_cbe)            { create(:exercise) }
      let(:exercise_cbe_to_return)  { create(:exercise, state: 'correcting') }
      let(:cbe)                     { create(:cbe) }
      let(:cbe_question)            { create(:cbe_question, :with_section) }
      let(:cbe_user_log)            { create(:cbe_user_log, cbe: cbe, exercise: exercise_cbe) }
      let!(:cbe_user_log_to_return) { create(:cbe_user_log, cbe: cbe, exercise: exercise_cbe_to_return, status: 'corrected') }
      let!(:cbe_user_question)      { create(:cbe_user_question, user_log: cbe_user_log, cbe_question: cbe_question) }

      before do
        allow_any_instance_of(SlackService).to receive(:notify_channel).and_return(false)
        allow_any_instance_of(Exercise).to receive(:correction_returned_email).and_return(false)

        exercise_cbe.submit
      end

      describe 'GET /admin/exercises/:id/correct_cbe' do

        it 'redirects the user' do
          get :correct_cbe, params: { id: exercise_cbe.id }

          expect(response.status).to eq(200)
          expect(response).to render_template(:correct_cbe)
        end
      end

      describe 'POST /admin/exercises/:id/cbe_user_question_update/answer/:question_id' do
        it 'update cbe question data' do
          post :cbe_user_question_update,
               params: { id: exercise_cbe.id, question_id: cbe_user_question.id, format: :js }

          expect(response.status).to eq(200)
          expect(response).to render_template(:cbe_user_question_update)
        end
      end

      describe 'POST /admin/exercises/:id/cbe_user_educator_comment/cbe_user_log/:cbe_user_log_id' do
        it 'update cbe question data' do
          post :cbe_user_educator_comment,
               params: { id: exercise_cbe.id, cbe_user_log_id: cbe_user_log.id, format: :js }

          expect(response.status).to eq(200)
          expect(response).to render_template(:cbe_user_educator_comment)
        end
      end

      describe 'POST/admin/exercises/:id/return_cbe' do
        it 'should return cbe correction to user' do
          post :return_cbe, params: { id: exercise_cbe_to_return.id }

          expect(response.status).to eq(302)
          redirect_to(admin_exercises_path)
        end

        it 'should redirect to correction' do
          post :return_cbe, params: { id: exercise_cbe.id }

          expect(response.status).to eq(200)
          expect(response).to render_template(:correct_cbe)
        end
      end
    end
  end
end
