# frozen_string_literal: true

require 'rails_helper'

describe FooterPagesController, type: :controller do
  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }

  let!(:course_1)  { FactoryBot.create(:active_course) }
  let(:tutor_user_group) { FactoryBot.create(:tutor_user_group) }
  let(:tutor_user_1) { FactoryBot.create(:tutor_user, user_group_id: tutor_user_group.id) }
  let!(:course_tutor_1) { FactoryBot.create(:course_tutor, user_id: tutor_user_1.id, course_id: course_1.id) }

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
