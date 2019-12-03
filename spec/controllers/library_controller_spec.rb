require 'rails_helper'

RSpec.describe LibraryController, type: :controller do

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }
  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group, exam_body_id: exam_body_1.id) }
  let!(:group_2) { FactoryBot.create(:group, exam_body_id: exam_body_1.id) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:subject_course_2)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               computer_based: true,
                                               exam_body_id: exam_body_1.id) }

  let!(:mock_exam_1) { FactoryBot.create(:mock_exam, subject_course_id: subject_course_1.id) }
  let!(:product_1) { FactoryBot.create(:product, mock_exam_id: mock_exam_1.id, currency_id: gbp.id, group_id: group_1.id) }

  context 'Not logged in: ' do

    describe 'GET index' do
      it 'renders the index view as 2 groups are active' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(Group.count).to eq(2)
      end

      it 'redirects to render to group_show as 1 group is active' do
        group_2.update_attribute(:active, false)
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(library_group_url(group_name_url: group_1.name_url))
        expect(Group.all_active.count).to eq(1)
      end
    end

    describe 'GET group_show' do
      it 'returns http success' do
        get :group_show, params: { group_name_url: group_1.name_url }
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(2)
      end
    end

    describe 'GET course_show' do
      it 'returns http success' do
        get :course_show, params: { subject_course_name_url: subject_course_1.name_url, group_name_url: group_1.name_url }
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(SubjectCourse.count).to eq(2)
      end
    end

  end

end
