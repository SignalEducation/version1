require 'rails_helper'

RSpec.describe UserSessionsController, :type => :controller do

  #
  # TODO - Whats going on here
  # Need a create tests for each possible redirect and student updates
  # Need a session destroy test
  # Need test for blocked user group users
  # Need test for users that need email verification and PW Reset

  describe "GET new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

end
