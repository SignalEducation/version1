require 'rails_helper'

RSpec.describe ExercisesController, type: :controller do
  let(:sys_group)      { create(:system_requirements_user_group) }
  let(:sys_user)       { create(:system_requirements_user, user_group_id: sys_group.id) }
  let(:exercise)       { create(:exercise, user: sys_user) }
  let(:other_user)     { create(:user) }
  let(:other_exercise) { create(:exercise, user: other_user) }

  before(:each) do
    activate_authlogic
    UserSession.create!(sys_user)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { user_id: sys_user.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #edit' do
    context 'exercise of current user' do
      it 'returns http success' do
        get :edit, params: { user_id: sys_user.id, id: exercise.id }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
      end
    end

    context 'exercise of other user' do
      it 'returns http redirect' do
        get :edit, params: { user_id: other_user.id, id: other_exercise.id }

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'GET #update' do
    context 'update user exercise' do
      it 'returns http redirect' do
        allow_any_instance_of(Paperclip::Attachment).to receive(:present?).and_return(true)
        allow_any_instance_of(SlackService).to receive(:notify_channel).and_return(false)
        put :update, params: { user_id: sys_user.id, id: exercise.id, exercise: exercise.attributes }

        expect(flash[:error]).to eq(nil)
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(exercise_path(exercise))
      end
    end

    context 'not update user exercise' do
      it 'returns http redirect after error' do
        put :update, params: { user_id: sys_user.id, id: exercise.id, exercise: exercise.attributes }

        expect(flash[:error]).to eq('Submission unsuccessful. You must upload a submission file.')
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_exercise_path(exercise))
      end
    end

    context 'not update user exercise' do
      it 'returns http redirect after error' do
        expect_any_instance_of(Exercise).to receive(:update).and_return(false)
        put :update, params: { user_id: sys_user.id, id: exercise.id, exercise: exercise.attributes }

        expect(flash[:error]).to eq('Unable to upload your submission')
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_exercise_path(exercise))
      end
    end
  end
end
