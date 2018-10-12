require 'rails_helper'
require 'support/users_and_groups_setup'

describe ApplicationController, type: :controller do

  include_context 'users_and_groups_setup'
  access_list = %w()

  controller do
    before_action do
      logged_in_required
    end
    before_action do
      ensure_user_has_access_rights(access_list)
    end

    def index
      render text: 'Hello'
    end
  end

  describe 'handling logged_in_required before_action as a student_user' do

    it 'should allow access' do
      activate_authlogic
      UserSession.create!(valid_trial_student)
      access_list = %w(student_user)
      get :index
      expect(flash[:success]).to be_nil
      expect(flash[:error]).to be_nil
      expect(response.status).to eq(200)
    end

    it 'should redirect with ERROR not signed in' do
      get :index
      expect_bounce_as_not_signed_in
    end
  end

  describe 'handling access_rights before_action as a student_user' do
    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
    end

    it 'should allow access' do
      access_list = %w(student_user)
      get :index
      expect(flash[:success]).to be_nil
      expect(flash[:error]).to be_nil
      expect(response.status).to eq(200)
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w()
      get :index
      expect_bounce_as_not_allowed
    end
  end

  describe 'handling access_rights before_action as a comp_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    it 'should redirect with ERROR not permitted' do
      #Access is denied here because complimentary users are not trial_or_sub_required
      access_list = %w(student_user)
      get :index
      expect_bounce_as_not_allowed
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w()
      get :index
      expect_bounce_as_not_allowed
    end
  end

  describe 'handling access_rights before_action as a tutor_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    it 'should redirect with ERROR not permitted' do
      #Access is denied here because tutor users are not trial_or_sub_required
      access_list = %w(student_user)
      get :index
      expect_bounce_as_not_allowed
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w()
      get :index
      expect_bounce_as_not_allowed
    end
  end

  describe 'handling access_rights before_action as a system_requirements_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(system_requirements_user)
    end

    it 'should allow access' do
      access_list = %w(system_requirements_access)
      get :index
      expect(flash[:success]).to be_nil
      expect(flash[:error]).to be_nil
      expect(response.status).to eq(200)
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w()
      get :index
      expect_bounce_as_not_allowed
    end
  end

  describe 'handling access_rights before_action as a content_management_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    it 'should allow access' do
      access_list = %w(content_management_access)
      get :index
      expect(flash[:success]).to be_nil
      expect(flash[:error]).to be_nil
      expect(response.status).to eq(200)
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w()
      get :index
      expect_bounce_as_not_allowed
    end
  end

  describe 'handling access_rights before_action as a stripe_management_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(stripe_management_user)
    end

    it 'should allow access' do
      access_list = %w(stripe_management_access)
      get :index
      expect(flash[:success]).to be_nil
      expect(flash[:error]).to be_nil
      expect(response.status).to eq(200)
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w()
      get :index
      expect_bounce_as_not_allowed
    end
  end

  describe 'handling access_rights before_action as a user_management_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    it 'should allow access' do
      access_list = %w(user_management_access)
      get :index
      expect(flash[:success]).to be_nil
      expect(flash[:error]).to be_nil
      expect(response.status).to eq(200)
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w()
      get :index
      expect_bounce_as_not_allowed
    end
  end

  describe 'handling access_rights before_action as a developers_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(developers_user)
    end

    it 'should allow access' do
      access_list = %w(developer_access)
      get :index
      expect(flash[:success]).to be_nil
      expect(flash[:error]).to be_nil
      expect(response.status).to eq(200)
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w()
      get :index
      expect_bounce_as_not_allowed
    end
  end

  describe 'handling access_rights before_action as a marketing_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    it 'should allow access' do
      access_list = %w(marketing_resources_access)
      get :index
      expect(flash[:success]).to be_nil
      expect(flash[:error]).to be_nil
      expect(response.status).to eq(200)
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w()
      get :index
      expect_bounce_as_not_allowed
    end
  end

  describe 'handling access_rights before_action as a user_group_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_group_manager_user)
    end

    it 'should allow access' do
      access_list = %w(user_group_management_access)
      get :index
      expect(flash[:success]).to be_nil
      expect(flash[:error]).to be_nil
      expect(response.status).to eq(200)
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w()
      get :index
      expect_bounce_as_not_allowed
    end
  end

  describe 'handling access_rights before_action as a admin_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    it 'should allow access' do
      access_list = %w(system_requirements_access content_management_access stripe_management_access user_management_access marketing_resources_access user_group_management_access)
      get :index
      expect(flash[:success]).to be_nil
      expect(flash[:error]).to be_nil
      expect(response.status).to eq(200)
    end

    it 'should redirect with ERROR not permitted' do
      access_list = %w(developer_access)
      get :index
      expect_bounce_as_not_allowed
    end
  end

end
