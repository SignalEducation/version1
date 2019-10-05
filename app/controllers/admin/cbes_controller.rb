# frozen_string_literal: true

module Admin
  class CbesController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[system_requirements_access]) }
    before_action :management_layout

    skip_before_action :verify_authenticity_token

    def index
      @cbes = Cbe.all.order(created_at: :desc)
    end

    def show
      @cbe = Cbe.find(params[:id])
    end

    def new; end
  end
end
