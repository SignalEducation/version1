# frozen_string_literal: true

module Admin
  class BearersController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[system_requirements_access]) }
    before_action :management_layout
    before_action :set_bearer, only: %i[edit update]

    def index
      @bearers = Bearer.all
    end

    def new
      @bearer = Bearer.new
    end

    def create
      @bearer = Bearer.new(bearer_params)

      if @bearer.save
        flash[:success] = t('controllers.bearers.create.flash.success')
        redirect_to admin_bearers_path
      else
        flash[:error] = t('controllers.bearers.create.flash.error')
        redirect_to admin_bearer_path(@bearer)
      end
    end

    def update
      if @bearer.update(bearer_params)
        flash[:success] = t('controllers.bearers.update.flash.success')
        redirect_to admin_bearers_path
      else
        flash[:error] = t('controllers.bearers.update.flash.error')
        redirect_to edit_admin_bearer_path(@bearer)
      end
    end

    def edit; end

    protected

    def set_bearer
      @bearer = Bearer.find(params[:id])
    end

    def bearer_params
      params.require(:bearer).permit(:name, :slug, :status)
    end
  end
end
