# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryController, type: :controller do
  let!(:gbp)               { create(:gbp) }
  let!(:uk)                { create(:uk, currency_id: gbp.id) }
  let!(:exam_body_1)       { create(:exam_body) }
  let!(:group_1)           { create(:group, exam_body: exam_body_1) }
  let!(:group_2)           { create(:group, exam_body: exam_body_1) }
  let!(:level_1)           { create(:level, group: group_1) }
  let!(:level_2)           { create(:level, group: group_1) }
  let!(:course_1)          { create(:active_course,
                                    level: level_1,
                                    group: group_1,
                                    exam_body: exam_body_1) }
  let!(:course_2)          { create(:active_course,
                                    group: group_1,
                                    level: level_1,
                                    computer_based: true,
                                    exam_body_id: exam_body_1.id) }

  let!(:mock_exam_1)       { create(:mock_exam, course_id: course_1.id) }
  let!(:product_1)         { create(:product, mock_exam_id: mock_exam_1.id, currency_id: gbp.id, group_id: group_1.id) }

  let!(:user)              { create(:user) }
  let!(:course_log)        { create(:course_log, course_id: course_1.id, user_id: user.id) }

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
    context 'with group' do
      it 'returns http success' do
        get :group_show, params: { group_name_url: group_1.name_url }
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:group_show)
        expect(Group.all_active.count).to eq(2)
        expect(Course.count).to eq(2)
      end
    end

    context 'without group' do
      it 'redirect to root url' do
        get :group_show, params: { group_name_url: 'any/url/here' }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET course_show' do
    context 'logged user' do
      it 'has_sittings present' do
        allow(controller).to receive(:current_user).and_return(user)
        allow_any_instance_of(ExamBody).to receive(:has_sittings).and_return(true)

        get :course_show, params: { course_name_url: course_1.name_url, group_name_url: group_1.name_url }
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(Course.count).to eq(2)
      end

      it 'has_sittings ausent' do
        allow(controller).to receive(:current_user).and_return(build(:user))

        get :course_show, params: { course_name_url: course_1.name_url, group_name_url: group_1.name_url }
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_show)
        expect(Group.all_active.count).to eq(2)
        expect(Course.count).to eq(2)
      end
    end

    context 'not logged user' do
      it 'returns course_preview' do
        allow_any_instance_of(Course).to receive(:preview).and_return(true)

        get :course_show, params: { course_name_url: course_1.name_url, group_name_url: group_1.name_url }
        expect(response).to have_http_status(:success)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:course_preview)
        expect(Group.all_active.count).to eq(2)
        expect(Course.count).to eq(2)
      end
    end
  end

  describe 'POST user_contact_form' do
    it 'redirect and return a success message' do
      expect(Zendesk::RequestWorker).to receive(:perform_async).and_return(true)

      post :user_contact_form, params: { full_name: 'John Doe', email_address: 'johndoe77@unknownemail.com', type: 'Contact Us', question: 'Where is the contact form?' }

      expect(flash[:success]).to eq('Thank you! Your submission was successful. We will contact you shortly.')
      expect(response.status).to eq(302)
    end

    it 'redirect and cancel submission with unverified recaptcha' do
      allow(controller).to receive(:verify_recaptcha).and_return(false)

      post :user_contact_form, params: { full_name: 'John Doe', email_address: 'johndoe77@unknownemail.com', type: 'Contact Us', question: 'Where is the contact form?' }

      expect(flash[:success]).to be_nil
      expect(flash[:error]).to eq('Your submission was not successful. Please try again.')
      expect(response.status).to eq(302)
    end

    it 'redirect and cancel submission with missing param' do
      post :user_contact_form, params: { full_name: 'John Doe', email_address: 'johndoe77@unknownemail.com', type: 'Contact Us' }

      expect(flash[:success]).to be_nil
      expect(flash[:error]).to eq('Your submission was not successful. Please try again.')
      expect(response.status).to eq(302)
    end

    it 'redirect and cancel submission with empty param' do
      post :user_contact_form, params: { full_name: 'John Doe', email_address: 'johndoe77@unknownemail.com', type: 'Contact Us', question: '' }

      expect(flash[:success]).to be_nil
      expect(flash[:error]).to eq('Your submission was not successful. Please try again.')
      expect(response.status).to eq(302)
    end
  end
end
