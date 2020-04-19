# frozen_string_literal: true

module Admin
  class CbesController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[content_management_access]) }
    before_action :management_layout
    before_action :set_cbe, only: %i[show clone]

    skip_before_action :verify_authenticity_token

    def index
      @cbes = Cbe.all.order(created_at: :desc)
    end

    def show; end

    def new; end

    def clone
      if @cbe.duplicate
        flash[:success] = 'Cbe successfully duplicated'
      else
        flash[:error] = 'Cbe not successfully duplicated'
      end

      redirect_to admin_cbes_path
    end

    private

    def set_cbe
      @cbe = Cbe.find(params[:id])
    end
  end
end
