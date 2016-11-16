# == Schema Information
#
# Table name: static_page_uploads
#
#  id                  :integer          not null, primary key
#  description         :string
#  static_page_id      :integer
#  created_at          :datetime
#  updated_at          :datetime
#  upload_file_name    :string
#  upload_content_type :string
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#

require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe StaticPageUploadsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:static_page_upload) { FactoryGirl.create(:static_page_upload)}
  let!(:valid_params) { FactoryGirl.attributes_for(:static_page_upload) }

  context 'Not logged in: ' do

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end
  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, static_page_upload: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should respond ERROR not permitted' do
        post :create, static_page_upload: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, static_page_upload: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should respond ERROR not permitted' do
        post :create, static_page_upload: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, static_page_upload: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should respond ERROR not permitted' do
        post :create, static_page_upload: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, static_page_upload: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should respond ERROR not permitted' do
        post :create, static_page_upload: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, static_page_upload: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should respond ERROR not permitted' do
        post :create, static_page_upload: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, static_page_upload: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, static_page_upload: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, static_page_upload: valid_params
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template (:show)
        expect(assigns('static_page_upload'.to_sym).class.name).to eq('static_page_upload'.classify)

      end

      it 'should report error for invalid params' do
        post :create, static_page_upload: {valid_params.keys.first => ''}
        expect(response.status).to eq(422)
      end
    end
  end

end
