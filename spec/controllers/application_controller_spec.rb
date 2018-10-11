require 'rails_helper'
require 'support/users_and_groups_setup'

describe ApplicationController, type: :controller do

  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
    UserSession.create!(student_user)
  end

  controller do
    before_action do
      ensure_user_has_access_rights(%w())
    end

    def index
      render text: 'Hello'
    end
  end


  describe 'handling before_action ensure_user_has_access_rights' do

    it 'should redirect with ERROR not permitted' do
      get :index
      expect_bounce_as_not_allowed
    end
  end

end
