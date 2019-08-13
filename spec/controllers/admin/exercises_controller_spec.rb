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
          exercise: { product_id: exercise.product_id },
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
        expect(flash[:success]).to eq 'Daily summary sent to Slack'
      end
    end
  end
end
