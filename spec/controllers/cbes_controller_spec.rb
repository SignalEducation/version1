require 'rails_helper'

RSpec.describe CbesController, type: :controller do
  let(:sys_group) { create(:system_requirements_user_group) }
  let(:sys_user)  { create(:system_requirements_user, user_group_id: sys_group.id) }
  let(:cbe)       { create(:cbe) }
  let!(:pages)    { create_list(:cbe_introduction_page, 5, cbe: cbe) }
  let(:exercise)  { create(:exercise) }

  before(:each) do
    activate_authlogic
    UserSession.create!(sys_user)
  end

  describe 'GET show' do
    it 'user has purchased a CBE' do
      expect_any_instance_of(User).to receive('purchased_cbe?').and_return(true)

      get :show, params: { id: cbe.id, exercise_id: exercise.id }
      expect(response.status).to eq(200)
      expect(flash[:error]).to be_nil
    end

    it 'user has not purchased a CBE' do
      expect_any_instance_of(User).to receive('non_student_user?').and_return(false)

      get :show, params: { id: cbe.id, exercise_id: exercise.id }
      expect(response.status).to eq(302)
      expect(response).to redirect_to(prep_products_url)
      expect(flash[:error]).to be_present
      expect(flash[:error]).to eq('You need to purchase it before access.')
    end

    it 'user has been assigned a complimentary exercise (of the CBE)' do
      allow_any_instance_of(User).to receive('purchased_cbe?').and_return(false)
      allow_any_instance_of(User).to receive('non_student_user?').and_return(false)
      allow_any_instance_of(User).to receive('exercise_ids').and_return([exercise.id])

      get :show, params: { id: cbe.id, exercise_id: exercise.id }
      expect(response.status).to eq(200)
      expect(flash[:error]).to be_nil
    end

    it 'user has NOT been assigned a complimentary exercise (of the CBE)' do
      expect_any_instance_of(User).to receive('purchased_cbe?').and_return(false)
      expect_any_instance_of(User).to receive('non_student_user?').and_return(false)

      get :show, params: { id: cbe.id, exercise_id: exercise.id }
      expect(response.status).to eq(302)
      expect(response).to redirect_to(prep_products_url)
      expect(flash[:error]).to be_present
      expect(flash[:error]).to eq('You need to purchase it before access.')
    end

    it 'user has a peding exercise' do
      get :show, params: { id: cbe.id, exercise_id: exercise.id }
      expect(response.status).to eq(200)
      expect(flash[:error]).to be_nil
    end

    it 'user has not a peding exercise' do
      expect_any_instance_of(User).to receive('purchased_cbe?').and_return(true)
      expect_any_instance_of(User).to receive('non_student_user?').and_return(false)

      exercise.update(state: 'submitted')

      get :show, params: { id: cbe.id, exercise_id: exercise.id }
      expect(response.status).to eq(302)
      expect(response).to redirect_to(prep_products_url)
      expect(flash[:error]).to be_present
      expect(flash[:error]).to eq('You do not have access to this CBE.')
    end
  end
end
