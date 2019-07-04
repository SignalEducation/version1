require 'rails_helper'

describe FooterPagesController, type: :controller do

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }

  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course) }
  let(:tutor_user_group) { FactoryBot.create(:tutor_user_group) }
  let(:tutor_user_1) { FactoryBot.create(:tutor_user, user_group_id: tutor_user_group.id) }
  let!(:tutor_student_access_1) { FactoryBot.create(:complimentary_student_access, user_id: tutor_user_1.id) }
  let!(:course_tutor_detail_1) { FactoryBot.create(:course_tutor_detail, user_id: tutor_user_1.id, subject_course_id: subject_course_1.id) }


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

    describe "Post 'complaints_intercom'" do
      #TODO - fix this post to intercom
      xit 'should render with 200' do
        post :complaints_intercom
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end

      xit 'should reject with invalid params' do
        post :complaints_intercom
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

    describe "Post 'contact_us_intercom'" do
      #TODO - fix this post to intercom
      xit 'should respond OK to valid params' do
        post :contact_us_intercom
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end

      xit 'should reject with invalid params' do
        post :contact_us_intercom
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:profile_index)

      end
    end

  end

end
