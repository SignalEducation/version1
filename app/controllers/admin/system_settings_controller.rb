# frozen_string_literal: true

module Admin
  class SystemSettingsController < ApplicationController
    before_action :logged_in_required
    before_action { ensure_user_has_access_rights(%w[system_requirements_access]) }
    before_action :management_layout
    before_action :system_setting

    def index; end

    def update
      @system.update(settings: settings_params)

      redirect_to(admin_system_settings_path)
    end

    private

    def system_setting
      @system = SystemSetting.find_by(environment: Rails.env)
    end

    # We need to add here any new value of settings
    def settings_params
      params.require(:settings).permit([:vimeo_as_main_player?])
    end
  end
end
