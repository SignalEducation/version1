# == Schema Information
#
# Table name: user_groups
#
#  id                           :integer          not null, primary key
#  name                         :string
#  description                  :text
#  tutor                        :boolean          default(FALSE), not null
#  site_admin                   :boolean          default(FALSE), not null
#  created_at                   :datetime
#  updated_at                   :datetime
#  system_requirements_access   :boolean          default(FALSE)
#  content_management_access    :boolean          default(FALSE)
#  stripe_management_access     :boolean          default(FALSE)
#  user_management_access       :boolean          default(FALSE)
#  developer_access             :boolean          default(FALSE)
#  user_group_management_access :boolean          default(FALSE)
#  student_user                 :boolean          default(FALSE)
#  trial_or_sub_required        :boolean          default(FALSE)
#  blocked_user                 :boolean          default(FALSE)
#  marketing_resources_access   :boolean          default(FALSE)
#

require 'rails_helper'

describe UserGroupsController, type: :controller do

  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let(:user_group_manager_user_group) { FactoryBot.create(:user_group_manager_user_group) }
  let(:user_group_manager_user) { FactoryBot.create(:user_group_manager_user, user_group_id: user_group_manager_user_group.id) }
  let!(:user_group_manager_student_access) { FactoryBot.create(:complimentary_student_access, user_id: user_group_manager_user.id) }

  let!(:valid_params) { FactoryBot.attributes_for(:user_group) }

  context 'Logged in as a user_group_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_group_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond with OK' do
        get :index
        expect_index_success_with_model('user_groups', UserGroup.all.count)
      end
    end

    describe "GET 'show/1'" do
      it 'should respond with OK' do
        get :show, id: student_user_group.id
        expect_show_success_with_model('user_group', student_user_group.id)
      end

        it 'should respond with OK if I ask for another' do
        get :show, id: user_group_manager_user_group.id
        expect_show_success_with_model('user_group', user_group_manager_user_group.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond with OK' do
        get :new
        expect_new_success_with_model('user_group')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: student_user_group.id
        expect_edit_success_with_model('user_group', student_user_group.id)
        end

      it 'should respond with OK' do
        get :edit, id: user_group_manager_user_group.id
        expect_edit_success_with_model('user_group', user_group_manager_user_group.id)
      end
    end

    describe "POST 'create'" do
      it 'should respond with OK to good input' do
        post :create, user_group: valid_params
        expect_create_success_with_model('user_group', user_groups_url)
      end

      it 'should reload the form for bad input' do
        post :create, user_group: {name: '', description: ''}
        expect_create_error_with_model('user_group')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid input' do
        put :update, id: student_user_group.id, user_group: valid_params
        expect_update_success_with_model('user_group', user_groups_url)
      end

      it 'should reload the edit page on invalid input' do
        put :update, id: student_user_group.id, user_group: {name: ''}
        expect_update_error_with_model('user_group')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should allow the deletion as dependant has been deleted too' do
        student_user_group.users.destroy_all
        delete :destroy, id: student_user_group.id
        expect_delete_success_with_model('user_group', user_groups_url)
      end

      it 'should fail to delete as dependant exists' do
        delete :destroy, id: user_group_manager_user_group.id
        expect_delete_error_with_model('user_group', user_groups_url)
      end
    end

  end

end
