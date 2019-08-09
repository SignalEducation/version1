# frozen_string_literal: true

module Admin
  class CbesController < ApplicationController
    before_action :logged_in_required
    before_action do
      ensure_user_has_access_rights(%w(system_requirements_access))
    end
    before_action :get_variables

    skip_before_action :verify_authenticity_token

    def index
      @cbes = Cbe.all
    end

    def new; end

    protected

    def get_variables
      @layout = 'management'
    end
  end
end
