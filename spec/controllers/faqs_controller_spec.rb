# == Schema Information
#
# Table name: faqs
#
#  id              :integer          not null, primary key
#  name            :string
#  name_url        :string
#  active          :boolean          default(TRUE)
#  sorting_order   :integer
#  faq_section_id  :integer
#  question_text   :text
#  answer_text     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pre_answer_text :text
#

require 'rails_helper'

describe FaqsController, type: :controller do

  let(:marketing_manager_user_group) { FactoryBot.create(:marketing_manager_user_group) }
  let(:marketing_manager_user) { FactoryBot.create(:marketing_manager_user, user_group_id: marketing_manager_user_group.id) }
  let!(:marketing_manager_student_access) { FactoryBot.create(:complimentary_student_access, user_id: marketing_manager_user.id) }

  let!(:faq_section_1) { FactoryBot.create(:faq_section) }
  let!(:faq_section_2) { FactoryBot.create(:faq_section) }

  let!(:faq_1) { FactoryBot.create(:faq, faq_section_id: faq_section_1.id) }
  let!(:faq_2) { FactoryBot.create(:faq, faq_section_id: faq_section_2.id) }
  let!(:faq_3) { FactoryBot.create(:faq, faq_section_id: faq_section_2.id, active: false) }
  let!(:valid_params) { FactoryBot.attributes_for(:faq) }

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, faq_section_id: faq_section_1.id
        expect_new_success_with_model('faq')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with faq_1' do
        get :edit, id: faq_1.id, faq_section_id: faq_section_1.id
        expect_edit_success_with_model('faq', faq_1.id)
      end

      # optional
      it 'should respond OK with faq_2' do
        get :edit, id: faq_2.id, faq_section_id: faq_section_2.id
        expect_edit_success_with_model('faq', faq_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, faq: valid_params, faq_section_id: faq_section_1.id
        expect_create_success_with_model('faq', public_resources_url)
      end

      it 'should report error for invalid params' do
        post :create, faq: {valid_params.keys.first => ''}, faq_section_id: faq_section_1.id
        expect_create_error_with_model('faq')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for faq_1' do
        put :update, id: faq_1.id, faq: valid_params
        expect_update_success_with_model('faq', public_resources_url)
      end

      # optional
      it 'should respond OK to valid params for faq_2' do
        put :update, id: faq_2.id, faq: valid_params
        expect_update_success_with_model('faq', public_resources_url)
        expect(assigns(:faq).id).to eq(faq_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: faq_1.id, faq: {valid_params.keys.first => ''}
        expect_update_error_with_model('faq')
        expect(assigns(:faq).id).to eq(faq_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [faq_2.id, faq_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: faq_3.id
        expect_delete_success_with_model('faq', public_resources_url)
      end
    end

  end

end
