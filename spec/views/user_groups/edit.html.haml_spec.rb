require 'rails_helper'

RSpec.describe 'user_groups/edit', type: :view do
  before(:each) do
    @user_group = FactoryGirl.create(:user_group)
  end

  it 'renders new user_group form' do
    render
    assert_select 'form[action=?][method=?]', user_group_path(id: @user_group.id), 'post' do
      assert_select 'input#user_group_name[name=?]', 'user_group[name]'
      assert_select 'textarea#user_group_description[name=?]', 'user_group[description]'
      assert_select 'input#user_group_individual_student[name=?]', 'user_group[individual_student]'
      assert_select 'input#user_group_tutor[name=?]', 'user_group[tutor]'
      assert_select 'input#user_group_content_manager[name=?]', 'user_group[content_manager]'
      assert_select 'input#user_group_blogger[name=?]', 'user_group[blogger]'
      assert_select 'input#user_group_corporate_customer[name=?]', 'user_group[corporate_customer]'
      assert_select 'input#user_group_site_admin[name=?]', 'user_group[site_admin]'
      assert_select 'input#user_group_forum_manager[name=?]', 'user_group[forum_manager]'
      assert_select 'input#user_group_subscription_required_at_sign_up[name=?]', 'user_group[subscription_required_at_sign_up]'
      assert_select 'input#user_group_subscription_required_to_see_content[name=?]', 'user_group[subscription_required_to_see_content]'
    end
  end
end
