# frozen_string_literal: true

require 'rails_helper'

describe FooterPagesController, type: :controller do
  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }

  let!(:course_1)  { FactoryBot.create(:active_course) }
  let(:tutor_user_group) { FactoryBot.create(:tutor_user_group) }
  let(:tutor_user_1) { FactoryBot.create(:tutor_user, user_group_id: tutor_user_group.id) }
  let!(:tutor_student_access_1) { FactoryBot.create(:complimentary_student_access, user_id: tutor_user_1.id) }
  let!(:course_tutor_1) { FactoryBot.create(:course_tutor, user_id: tutor_user_1.id, course_id: course_1.id) }

  context 'Not logged in: ' do
    describe "GET 'privacy_policy'" do
      it 'should render with 200' do
        get :privacy_policy
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:privacy_policy)
      end
    end

    describe "GET 'acca_info'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'contact'" do
      it 'should render with 200' do
        get :acca_info
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:acca_info)
      end
    end

    describe "Get 'terms_and_conditions'" do
      it 'should render with 200' do
        get :terms_and_conditions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:terms_and_conditions)
      end
    end

    describe "Get 'frequently_asked_questions'" do
      it 'should render with 200' do
        get :frequently_asked_questions
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:frequently_asked_questions)
      end
    end

    describe "Get 'media_library'" do
      it 'should render with 200' do
        request.env['remote_ip'] = ''
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
      end
    end

    describe "Get 'profile'" do
      it 'should render with 200' do
        get :profile, params: { name_url: tutor_user_1.name_url }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile)
      end
    end

    describe "Get 'profile_index'" do
      it 'should render with 200' do
        get :profile_index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)
      end
    end

    describe "Post 'info_subscribe'" do
      #TODO - fix this post to mailchimp
      xit 'should render with 200' do
        post :info_subscribe
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)
      end

      xit 'should reject with invalid params' do
        post :info_subscribe
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)
      end
    end
  end

  context 'Logged in: ' do
    let(:student_user_group ) { create(:student_user_group ) }
    let(:student)             { create(:basic_student, user_group: student_user_group) }

    before(:each) do
      activate_authlogic
      UserSession.create!(student)
    end

    describe "Get 'media_library'" do
      it 'should render with 200' do
        request.env['remote_ip'] = ''
        get :media_library
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:media_library)
      end
    end
  end
end
